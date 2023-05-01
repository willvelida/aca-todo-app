using Todo.Api.Common;

namespace Todo.Api.Repository.Interfaces
{
    public interface ITodoRepository
    {
        Task<IEnumerable<TodoItem>> GetTodoItemsByState(string state, int? skip, int? batch);
        Task AddItem(TodoItem item);
        Task<TodoItem> GetTodoItem(string itemId);
        Task DeleteTodoItem(string itemId);
        Task UpdateTodoItem(TodoItem existingTodoItem);
        Task<List<TodoItem>> GetAllTodoItems(int? skip, int? batchSize);
    }
}
