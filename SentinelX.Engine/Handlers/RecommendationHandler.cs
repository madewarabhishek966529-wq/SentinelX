using System;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Engine.Handlers
{
    public class RecommendationHandler : IRequestHandler
    {
        private readonly RecommendationService _service;

        public RecommendationHandler(RecommendationService service)
        {
            _service = service;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "get_recommendations", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            try
            {
                var recommendations = _service.EvaluateRecommendations();
                return IpcResponse<object>.CreateSuccess(request.RequestId, recommendations);
            }
            catch (Exception ex)
            {
                return IpcResponse<object>.CreateError(
                    request.RequestId,
                    "RECOMMENDATION_ERROR",
                    "Evaluation failed: " + ex.Message
                );
            }
        }
    }
}
