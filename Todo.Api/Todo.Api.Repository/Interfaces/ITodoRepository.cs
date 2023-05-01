using Todo.Api.Common;

namespace Todo.Api.Repository.Interfaces
{
    public interface ITodoRepository
    {
        Task<TodoItem> GetTodoItemByState(string state, int? skip, int? batch);
        Task AddItem(TodoItem item);
        Task<TodoItem> GetTodoItem(string itemId);
        Task DeleteTodoItem(string itemId);
        Task UpdateTodoItem(TodoItem existingTodoItem);
        Task<List<T>> GetAllTodoItems<T>(IQueryable<T> queryable, int? skip, int? batchSize);
    }
}
