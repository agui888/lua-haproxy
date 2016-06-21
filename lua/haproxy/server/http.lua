--- @module server

local http = {}

--- RFC2616 HTTP/1.1 status codes
http.status = {
  CONTINUE                        = 100, -- `100 Continue`
  SWITCHING_PROTOCOLS             = 101, -- `101 Switching Protocols`
  OK                              = 200, -- `200 OK`
  CREATED                         = 201, -- `201 Created`
  ACCEPTED                        = 202, -- `202 Accepted`
  NON_AUTHORITATIVE_INFORMATION   = 203, -- `203 Non-Authoritative Information`
  NO_CONTENT                      = 204, -- `204 No Content`
  RESET_CONTENT                   = 205, -- `205 Reset Content`
  PARTIAL_CONTENT                 = 206, -- `206 Partial Content`
  MULTIPLE_CHOICES                = 300, -- `300 Multiple Choices`
  MOVED_PERMANENTLY               = 301, -- `301 Moved Permanently`
  FOUND                           = 302, -- `302 Found`
  SEE_OTHER                       = 303, -- `303 See Other`
  NOT_MODIFIED                    = 304, -- `304 Not Modified`
  USE_PROXY                       = 305, -- `305 Use Proxy`
  TEMPORARY_REDIRECT              = 307, -- `307 Temporary Redirect`
  BAD_REQUEST                     = 400, -- `400 Bad Request`
  UNAUTHORIZED                    = 401, -- `401 Unauthorized`
  PAYMENT_REQUIRED                = 402, -- `402 Payment Required`
  FORBIDDEN                       = 403, -- `403 Forbidden`
  NOT_FOUND                       = 404, -- `404 Not Found`
  METHOD_NOT_ALLOWED              = 405, -- `405 Method Not Allowed`
  NOT_ACCEPTABLE                  = 406, -- `406 Not Acceptable`
  PROXY_AUTHENTICATION_REQUIRED   = 407, -- `407 Proxy Authentication Required`
  REQUEST_TIME_OUT                = 408, -- `408 Request Time-out`
  CONFLICT                        = 409, -- `409 Conflict`
  GONE                            = 410, -- `410 Gone`
  LENGTH_REQUIRED                 = 411, -- `411 Length Required`
  PRECONDITION_FAILED             = 412, -- `412 Precondition Failed`
  REQUEST_ENTITY_TOO_LARGE        = 413, -- `413 Request Entity Too Large`
  REQUEST_URI_TOO_LARGE           = 414, -- `414 Request-URI Too Large`
  UNSUPPORTED_MEDIA_TYPE          = 415, -- `415 Unsupported Media Type`
  REQUESTED_RANGE_NOT_SATISFIABLE = 416, -- `416 Requested range not satisfiable`
  EXPECTATION_FAILED              = 417, -- `417 Expectation Failed`
  IM_A_TEAPOT                     = 418, -- `I'm a teapot`
  INTERNAL_SERVER_ERROR           = 500, -- `500 Internal Server Error`
  NOT_IMPLEMENTED                 = 501, -- `501 Not Implemented`
  BAD_GATEWAY                     = 502, -- `502 Bad Gateway`
  SERVICE_UNAVAILABLE             = 503, -- `503 Service Unavailable`
  GATEWAY_TIME_OUT                = 504, -- `504 Gateway Time-out`
  HTTP_VERSION_NOT_SUPPORTED      = 505, -- `505 HTTP Version not supported`
}

--- RFC2616 HTTP/1.1 methods
http.method = {
  DELETE  = 'DELETE',
  GET     = 'GET',
  HEAD    = 'HEAD',
  OPTIONS = 'OPTIONS',
  PATCH   = 'PATCH',
  POST    = 'POST',
  PUT     = 'PUT',
}

return http
