---
applyTo: 'src/main/java/**/middleware/**/*.java,src/main/java/**/connector/**/*.java,src/main/java/**/service/**/*Service*.java'
---

## Middleware / External API Integration Pattern

When implementing a new middleware or external API integration, follow this exact layered pattern. There are **two variants**: one for **SOAP/XML middleware** (uses Thymeleaf XML templates + JAXB unmarshalling) and one for **REST/JSON external APIs** (uses Jackson directly).

### Folder Structure for Middleware Integrations

```
src/
├── main/
│   ├── java/ae/rakbank/<yourapp>/
│   │   ├── config/
│   │   │   └── <ServiceName>Config.java          # @ConfigurationProperties for URL(s) and API keys
│   │   ├── connector/
│   │   │   └── RestConnector.java                 # Generic REST connector with retry + activity logging
│   │   ├── dto/request/
│   │   │   └── ApiCallDetails.java                # Generic API call descriptor (shared across all integrations)
│   │   ├── entity/
│   │   │   └── ActivityLog.java                   # JPA entity for request/response audit trail
│   │   ├── enums/
│   │   │   ├── ActivityLogName.java               # Enum entry per integration (e.g. CARD_ACCOUNT_DETAILS)
│   │   │   ├── ActivityLogType.java               # REQUEST, RESPONSE
│   │   │   └── ErrorCodes.java                    # Centralized error code enum
│   │   ├── exception/
│   │   │   ├── ClientException.java               # Business-level MW failures (bad response codes)
│   │   │   ├── DownStreamException.java           # Base downstream exception
│   │   │   ├── DownStreamClientErrorException.java# 4xx from downstream
│   │   │   └── DownStreamFailureException.java    # 5xx / connectivity failures
│   │   ├── middleware/
│   │   │   ├── constants/
│   │   │   │   └── MiddlewareConstants.java       # MW-specific constants (success code, template param keys)
│   │   │   ├── response/gen/                      # JAXB-generated response classes from XSD/WSDL
│   │   │   └── service/
│   │   │       ├── AbstractMiddleware.java         # Base class: template resolver, HTTP headers, JAXB util
│   │   │       ├── MiddlewareBaseService.java      # Interface: T getData(R request, String requestId)
│   │   │       └── impl/
│   │   │           └── Middleware<Name>ServiceImpl.java  # Concrete implementation per MW API
│   │   ├── service/
│   │   │   ├── ClientConnectionService.java       # Alternative connector (MW-specific, same pattern as RestConnector)
│   │   │   └── TemplateResolverService.java       # Thymeleaf XML template rendering
│   └── resources/
│       └── templates/
│           └── <TemplateName>.xml                 # Thymeleaf XML SOAP request templates
```

---

### Layer 1: ApiCallDetails — The Universal API Call Descriptor

Every outbound API call (MW or REST) MUST be described using the `ApiCallDetails<R, T>` builder:

```java
@Getter
@Builder
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ApiCallDetails<R, T> {
    private String url;                    // Full endpoint URL
    private HttpMethod httpMethod;         // POST, GET, etc.
    private String requestId;              // Correlation/trace ID
    private R requestBody;                 // Request payload (String for XML, Object for JSON)
    private Class<T> responseType;         // Expected response class
    private ActivityLogName activityName;  // Enum value for this integration
    private String requestResponseId;      // UUID for linking request/response logs
    private HttpHeaders httpHeaders;       // HTTP headers
    private boolean isDBLoggingRequired;   // Toggle for activity log persistence
}
```

**Rules:**
- Always set `requestId` for traceability.
- Always set `activityName` to the correct enum constant.
- Set `isDBLoggingRequired` from `@Value("${<app>.activityLog.enable}")`.
- For JSON APIs, set `requestResponseId` to `UUID.randomUUID().toString()`.

---

### Layer 2: RestConnector / ClientConnectionService — Generic HTTP Executor

The connector provides `exchange()` and `exchangeForResponseEntity()` methods with:

1. **Spring Retry** via `@Retryable` with configurable `max-attempts` and `backoff delay` from properties:
   ```yaml
   downstream.api.retry.max-attempts: 3
   downstream.api.retry.max-delay-ms: 1000
   ```

2. **Structured exception mapping:**
   - `HttpStatusCodeException` with `4xx` → throw `DownStreamClientErrorException`
   - `HttpStatusCodeException` with `5xx` → throw `DownStreamFailureException`
   - Any other `Exception` → throw `DownStreamFailureException`

3. **Activity logging** — Both REQUEST and RESPONSE are logged:
   - Info-level log with requestId, URL, HTTP method, status code, response time.
   - If `isDBLoggingRequired` is true, persist an `ActivityLog` entity to the database.

4. **No retry** on `DownStreamClientErrorException` (4xx are not retried).

**Rules:**
- Do NOT create a new connector per integration. Reuse `RestConnector` (for JSON/REST APIs) or `ClientConnectionService` (for MW/SOAP APIs).
- The connector is `@Service` scoped — inject it into your service.

---

### Layer 3a: SOAP/XML Middleware Integration (Thymeleaf + JAXB)

For middleware APIs that communicate via XML/SOAP:

#### Step 1: Create the XML Request Template

Place in `src/main/resources/templates/<TemplateNameReq>.xml`. Use Thymeleaf literal substitutions `[[${variable}]]` for dynamic values:

```xml
<ns3:envelope xmlns:ns2="urn:RAKBankHeader" xmlns:ns3="urn:<ServiceName>_req">
   <ns3:header>
      <ns2:ServiceId>RBS_<ServiceName></ns2:ServiceId>
      <ns2:RequestID>[[${requestId}]]</ns2:RequestID>
      <ns2:TimeStampyyyymmddhhmmsss>[[${timeStamp}]]</ns2:TimeStampyyyymmddhhmmsss>
      <!-- ... other header fields ... -->
   </ns3:header>
   <ns3:body>
      <!-- dynamic request fields -->
      <ns3:SomeField>[[${someField}]]</ns3:SomeField>
   </ns3:body>
</ns3:envelope>
```

#### Step 2: Generate JAXB Response Classes

Generate from XSD/WSDL into `middleware/response/gen/<service_name>/` package. The response must have an `Envelope` class with `getBody()` returning the typed response, and a `StatusType` with `getStatusCode()` and `getStatusDesc()`.

#### Step 3: Add Config Properties

```java
@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "client.mw")
public class MiddlewareConfig {
    @NotNull
    private String <serviceName>Url;
}
```

#### Step 4: Add Constants

Add template param key constants and request type constant to `MiddlewareConstants`:

```java
public static final String MW_SUCCESS_RESPONSE_CODE = "0000";
public static final String <SERVICE_NAME>_REQ_TYPE = "<TemplateNameReq>";
// Add parameter key constants: FIELD_NAME = "fieldName"
```

#### Step 5: Add ActivityLogName Enum Value

```java
public enum ActivityLogName {
    // ...existing values...
    <SERVICE_NAME>,
}
```

#### Step 6: Implement the Middleware Service

```java
@Service
@Slf4j
public class Middleware<Name>ServiceImpl extends AbstractMiddleware
        implements MiddlewareBaseService<ResponseBodyType, RequestDataType> {

    @Value("${<app>.activityLog.enable}")
    private boolean isDbLoggingRequired;

    public Middleware<Name>ServiceImpl(TemplateResolverService templateResolverService,
                                       ClientConnectionService clientConnectionService,
                                       MiddlewareConfig middlewareConfig) {
        super(templateResolverService, clientConnectionService, middlewareConfig);
    }

    @Override
    public ResponseBodyType getData(RequestDataType data, String requestId) {
        try {
            // 1. Build template variables
            var root = Map.ofEntries(
                entry(REQUEST_ID, requestId),
                entry(TIMESTAMP, getHeaderTimeStamp()),
                entry(FIELD_KEY, data.getField())
            );
            // 2. Resolve XML from template
            var requestBody = templateResolverService.resolveXmlTemplate(SERVICE_REQ_TYPE, root);
            // 3. Build ApiCallDetails
            ApiCallDetails<?, String> apiCallDetails = ApiCallDetails.<Object, String>builder()
                    .url(middlewareConfig.get<ServiceName>Url())
                    .httpHeaders(getHttpHeaders(requestId))
                    .requestId(requestId)
                    .requestBody(requestBody)
                    .httpMethod(HttpMethod.POST)
                    .activityName(ActivityLogName.<SERVICE_NAME>)
                    .responseType(String.class)
                    .isDBLoggingRequired(isDbLoggingRequired)
                    .build();
            // 4. Execute call
            String exchange = clientConnectionService.exchange(apiCallDetails);
            // 5. Unmarshal XML response
            Envelope envelope = convertStringToJAXBObject(exchange, Envelope.class);
            // 6. Validate response
            if (envelope.getBody() == null || envelope.getBody().getStatus() == null) {
                throw new ClientException("Error from Client Empty response from MW",
                    ErrorCodes.CLIENT_ERROR.getErrorCode(), HttpStatus.INTERNAL_SERVER_ERROR);
            }
            if (!MW_SUCCESS_RESPONSE_CODE.equals(envelope.getBody().getStatus().getStatusCode())) {
                throw new ClientException(
                    ErrorCodes.CLIENT_ERROR.getErrorMessage(MIDDLEWARE_ERROR_MSG
                        + envelope.getBody().getStatus().getStatusDesc()),
                    ErrorCodes.CLIENT_ERROR.getErrorCode(), HttpStatus.INTERNAL_SERVER_ERROR);
            }
            // 7. Return typed body
            return envelope.getBody();
        } catch (IllegalArgumentException ex) {
            log.error("IllegalArgumentException: {}", ex.getMessage());
            throw new ClientException(ErrorCodes.CLIENT_ERROR.getErrorMessage(ex.getMessage()),
                ErrorCodes.CLIENT_ERROR.getErrorCode(), HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception ex) {
            log.error("Exception: {}", ex.getMessage());
            throw ex;
        }
    }
}
```

---

### Layer 3b: REST/JSON External API Integration

For JSON-based REST APIs (e.g. InfoBip, third-party services):

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class <ExternalService>Service {

    private final RestConnector restConnector;
    private final ObjectMapper objectMapper;
    private final <ExternalService>Config config;

    @Value("${<app>.activityLog.enable}")
    private boolean isDbLoggingRequired;

    public void callExternalApi(RequestData data) {
        // 1. Build JSON request body
        ObjectNode requestBody = objectMapper.createObjectNode();
        requestBody.put("field", data.getValue());

        // 2. Build ApiCallDetails
        ApiCallDetails<?, String> apiCallDetails = ApiCallDetails.<Object, String>builder()
                .url(config.getApiUrl())
                .httpHeaders(getHttpHeaders())
                .requestId(data.getRequestId())
                .requestBody(requestBody)
                .httpMethod(HttpMethod.POST)
                .activityName(ActivityLogName.<EXTERNAL_SERVICE_NAME>)
                .responseType(String.class)
                .requestResponseId(UUID.randomUUID().toString())
                .isDBLoggingRequired(isDbLoggingRequired)
                .build();

        // 3. Execute call
        var response = restConnector.exchangeForResponseEntity(apiCallDetails);

        // 4. Validate HTTP response
        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new AppException("Unable to call <ExternalService>");
        }
    }

    private HttpHeaders getHttpHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Authorization", "Bearer %s".formatted(config.getApiKey()));
        return headers;
    }
}
```

---

### AbstractMiddleware Base Class (for SOAP/XML only)

Provides three reusable methods inherited by all MW implementations:

| Method | Purpose |
|--------|---------|
| `getHeaderTimeStamp()` | Returns formatted timestamp `yyyy-MM-dd HH:mm:ss.[SSS]` |
| `convertStringToJAXBObject(body, class)` | Unmarshals XML string to JAXB object with error handling |
| `getHttpHeaders(requestId)` | Creates `APPLICATION_XML` headers with `x-api-request-id` |

---

### MiddlewareBaseService Interface

```java
public interface MiddlewareBaseService<T, R> {
    T getData(R r, String requestId);
}
```

All SOAP middleware implementations MUST implement this interface with the response type as `T` and the request data DTO as `R`.

---

### Thymeleaf XML Template Configuration

A `ThymeleafConfig` bean MUST be present:
- Template resolver prefix: `classpath:/templates/`
- Template resolver suffix: `.xml`
- Character encoding: `UTF-8`
- Caching: `false` (for development flexibility)

---

### RestTemplate Configuration

- **Local profile**: Trust-all SSL for development.
- **Non-local profiles**: Standard `RestTemplateBuilder.build()`.

---

### Exception Hierarchy

```
RuntimeException
├── ClientException              (MW business errors: bad status code, empty response)
│     Fields: message, errorCode (int), httpStatus
└── ProcessingException
    └── DownStreamException
        ├── DownStreamClientErrorException   (4xx from downstream, @ResponseStatus BAD_REQUEST)
        └── DownStreamFailureException       (5xx / connectivity, @ResponseStatus SERVICE_UNAVAILABLE)
```

---

### Testing Pattern

- Use `@Mock` for `TemplateResolverService`, `ClientConnectionService`/`RestConnector`, and config.
- Use `@InjectMocks` for the service under test.
- Test scenarios:
  1. **Success**: Mock template resolution → mock exchange returning valid XML/JSON → assert non-null typed response.
  2. **Failure - Empty/null response body**: Mock exchange returning XML with empty body → assert `ClientException`.
  3. **Failure - Bad status code**: Mock exchange returning XML with error status → assert `ClientException` with error message.
  4. **Failure - JAXB parse error**: Mock exchange returning invalid XML → assert `ClientException`.
  5. **Failure - Downstream error**: Mock exchange throwing `DownStreamFailureException` → assert propagation.

---

### Configuration Properties Pattern

```yaml
# Middleware
client:
  mw:
    card-account-details-url: ${MW_CARD_ACCOUNT_DETAILS_URL}
    # Add new MW endpoint URLs here

# External APIs
client:
  infobip:
    send-event-url: ${INFOBIP_SEND_EVENT_URL}
    api-key: ${INFOBIP_API_KEY}

# Retry configuration
downstream:
  api:
    retry:
      max-attempts: 3
      max-delay-ms: 1000

# Activity logging toggle
<app-name>:
  activityLog:
    enable: true
```

---

### Checklist for Adding a New Middleware Integration

- [ ] Create `@ConfigurationProperties` config class with URL(s) in `config/` package
- [ ] Add `ActivityLogName` enum constant
- [ ] Create XML request template in `src/main/resources/templates/` (SOAP only)
- [ ] Generate JAXB response classes from XSD/WSDL (SOAP only)
- [ ] Add constants to `MiddlewareConstants` (SOAP only)
- [ ] Implement service extending `AbstractMiddleware` + `MiddlewareBaseService` (SOAP) or as a standalone `@Service` using `RestConnector` (REST)
- [ ] Add endpoint URL to `application.properties`/`application.yml`
- [ ] Write unit tests covering success, empty response, error response, parse failure, and downstream exception scenarios
- [ ] Ensure `isDbLoggingRequired` is wired from application property
