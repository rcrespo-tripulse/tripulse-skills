# SAP B1 Service Layer Reference

Use this document for concrete patterns after reading `SKILL.md`.

## Official SAP Documentation (Primary Source)

Official URL (for real-time consultation):

https://help.sap.com/doc/0d2533ad95ba4ad7a702e83570a21c32/9.3/en-US/Working_with_SAP_Business_One_Service_Layer.pdf

Document identity:

- Title: `Working with SAP Business One Service Layer`
- Version: `1.15`
- Date: `2019-12-02`

When rules in this reference and live SAP behavior diverge, prefer the official PDF and verify against your installed SAP patch level.

## Key Points Extracted From Official PDF

These points were extracted from the official SAP PDF above and condensed for day-to-day API work.

### Authentication and Session

- Login endpoint: `POST /b1s/v1/Login`.
- Successful login sets cookies `B1SESSION` and `ROUTEID`.
- Logout endpoint: `POST /b1s/v1/Logout` and typically returns `204 No Content`.
- `B1SESSION` and `ROUTEID` are required on each request after login.
- Missing cookies can lead to `401 Unauthorized` with `Invalid session`.

### QueryService and Row-Level Filtering

- Row-level filtering is documented through `QueryService_PostQuery`.
- QueryService uses two payload properties:
  - `QueryPath` (for `$crossjoin(...)`)
  - `QueryOption` (for `$expand`, `$filter`, and related query clauses)

### Semantic Layer Service Root

- Semantic Layer root is `"/b1s/v1/sml.svc"` (separate from normal `b1s/v1` entity endpoints).
- Semantic Layer metadata endpoint is `GET /b1s/v1/sml.svc/$metadata`.

### Batch and Changesets

- Batch endpoint: `POST /b1s/v1/$batch`.
- Batch content type must be `multipart/mixed` with boundaries.
- Batch subrequests are processed sequentially.
- Changesets are atomic write groups and must not include `GET`.
- In OData v4 changesets, `Content-ID` is mandatory.
- Official limitations note that OData batch rollback operation is not supported beyond changeset transactional behavior.

### Configuration by Request and CORS

- Per-request override format: `B1S-<configuration-item-name>: <value>`.
- Example headers: `B1S-WCFCompatible: True`, `B1S-PageSize: 100`.
- CORS options include `CorsEnable`, `CorsAllowedOrigins`, and `CorsAllowedHeaders`.
- Browser CORS flow includes preflight `OPTIONS` requests.

### Relevant Limitations to Keep in Mind

- OData v1 and v2 are not supported.
- XML request/response is not supported for general CRUD.
- Direct SQL via `RecordSet` is not supported in Service Layer.
- Cross-request user transactions (`StartTransaction/EndTransaction` style) are not supported.

## Login and Session Cookies

```bash
curl --location 'https://sl.bunzlbi.mx:50000/b1s/v1/Login' \
  --header 'Content-Type: application/json' \
  --data '{
    "CompanyDB": "ESPOMEGA",
    "UserName": "****",
    "Password": "****"
  }'
```

Expected success response shape:

```json
{
  "odata.metadata": "https://sl.bunzlbi.mx:50000/b1s/v1/$metadata#B1Sessions/@Element",
  "SessionId": "cea10664-0546-11f1-c000-00155d01f301-82836-82528",
  "Version": "1000220",
  "SessionTimeout": 30
}
```

Reuse cookies in subsequent calls:

```bash
--header 'Cookie: B1SESSION=<session-id>; ROUTEID=<route-id>'
```

## Metadata Discovery

Read metadata before writing payloads:

```bash
curl --location 'https://<host>:50000/b1s/v1/$metadata' \
  --header 'Cookie: B1SESSION=<session-id>; ROUTEID=<route-id>'
```

Use `https://<host>:50000/b1s/v1/sml.svc/$metadata` for semantic layer resources.

## OData Query Examples

Read with selection, filtering, sorting, and paging:

```bash
curl --location 'https://<host>:50000/b1s/v1/BusinessPartners?$select=CardCode,CardName&$filter=CardType%20eq%20%27C%27&$orderby=CardCode%20asc&$top=20&$skip=0' \
  --header 'Cookie: B1SESSION=<session-id>; ROUTEID=<route-id>'
```

Count rows:

```bash
curl --location 'https://<host>:50000/b1s/v1/BusinessPartners/$count?$filter=CardType%20eq%20%27C%27' \
  --header 'Cookie: B1SESSION=<session-id>; ROUTEID=<route-id>'
```

## QueryService PostQuery

Use crossjoin for joined header/line filters:

```bash
curl --location 'https://<host>:50000/b1s/v1/QueryService_PostQuery' \
  --header 'Content-Type: application/json' \
  --header 'Cookie: B1SESSION=<session-id>; ROUTEID=<route-id>' \
  --data '{
    "QueryPath": "$crossjoin(Orders,Orders/DocumentLines)",
    "QueryOption": "$expand=Orders($select=DocEntry,DocNum),Orders/DocumentLines($select=ItemCode,LineNum)&$filter=Orders/DocEntry eq Orders/DocumentLines/DocEntry and Orders/DocDate ge 2024-01-01"
  }'
```

## Semantic Layer Aggregation

Aggregate by dimensions through `$apply`:

```bash
curl --location 'https://<host>:50000/b1s/v1/sml.svc/INCOMING_PAYMENTS?$apply=groupby((CardCode),aggregate(PaymentSum with sum as TotalPaid))' \
  --header 'Cookie: B1SESSION=<session-id>; ROUTEID=<route-id>'
```

## Batch and Changeset Skeleton

Use `multipart/mixed` with explicit boundaries:

```http
POST /b1s/v1/$batch HTTP/1.1
Content-Type: multipart/mixed; boundary=batch_123

--batch_123
Content-Type: multipart/mixed; boundary=changeset_456

--changeset_456
Content-Type: application/http
Content-Transfer-Encoding: binary
Content-ID: 1

POST Orders HTTP/1.1
Content-Type: application/json

{"CardCode":"C20000","DocumentLines":[{"ItemCode":"A00001","Quantity":1}]}

--changeset_456--
--batch_123--
```

Rules:

- Keep writes in a changeset.
- Keep `GET` outside changesets.
- Use `Content-ID` linking for same-changeset dependencies.

## Service Layer Configuration

Service file:

```text
ServiceLayer/conf/b1s.conf
```

Use `B1S-*` headers for request-level overrides, for example:

```http
B1S-PageSize: 100
```

Enable CORS with keys such as:

- `CorsEnable`
- `CorsAllowedOrigins`
- `CorsAllowedHeaders`
