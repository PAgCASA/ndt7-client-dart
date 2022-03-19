// SecWebSocketProtocol is the value of the Sec-WebSocket-Protocol header.
const SecWebSocketProtocol = "net.measurementlab.ndt.v7";

// MaxMessageSize is the maximum accepted message size.
const MaxMessageSize = 1 << 20;

// DownloadTimeout is the time after which the download must stop.
const DownloadTimeout = Duration(seconds: 15);

// IOTimeout is the timeout for I/O operations.
const IOTimeout = Duration(seconds: 7);

// DownloadURLPath is the URL path used for the download.
const DownloadURLPath = "/ndt/v7/download";

// UploadURLPath is the URL path used for the download.
const UploadURLPath = "/ndt/v7/upload";

// UploadTimeout is the time after which the upload must stop.
const UploadTimeout = Duration(seconds: 10);

// BulkMessageSize is the size of uploaded messages
const BulkMessageSize = 1 << 13;

// UpdateInterval is the interval between client side upload measurements.
const UpdateInterval = Duration(milliseconds: 250);