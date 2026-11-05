using System;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Engine.Handlers
{
    public class ReportHandler : IRequestHandler
    {
        private readonly ReportService _service;

        public ReportHandler(ReportService service)
        {
            _service = service;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "generate_system_report", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "export_report", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            try
            {
                if (string.Equals(request.Action, "generate_system_report", StringComparison.OrdinalIgnoreCase))
                {
                    var data = _service.BuildSystemReport();
                    return IpcResponse<object>.CreateSuccess(request.RequestId, data);
                }

                if (string.Equals(request.Action, "export_report", StringComparison.OrdinalIgnoreCase))
                {
                    string format = "json";
                    if (request.Parameters != null && request.Parameters.ContainsKey("format"))
                    {
                        format = request.Parameters["format"]?.ToString() ?? "json";
                    }

                    string path = _service.ExportReport(format);
                    return IpcResponse<object>.CreateSuccess(request.RequestId, new
                    {
                        filePath = path,
                        format = format,
                        success = true
                    });
                }

                return IpcResponse<object>.CreateError(request.RequestId, "UNKNOWN_ACTION", "Unhandled report action: " + request.Action);
            }
            catch (Exception ex)
            {
                return IpcResponse<object>.CreateError(
                    request.RequestId,
                    "REPORT_ERROR",
                    "Report generation failed: " + ex.Message
                );
            }
        }
    }
}
