using SentinelX.Contracts;

namespace SentinelX.Engine.Handlers
{
    public interface IRequestHandler
    {
        bool CanHandle(string action);
        IpcResponse<object> Handle(IpcRequest request);
    }
}
