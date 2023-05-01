using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Todo.Api.Common;
using Todo.Api.Repository.Interfaces;

namespace Todo.Api.Repository
{
    public class TodoRepository : ITodoRepository
    {
        public Task AddItem(TodoItem item)
        {
            throw new NotImplementedException();
        }

        public Task DeleteTodoItem(string itemId)
        {
            throw new NotImplementedException();
        }

        public Task<List<T>> GetAllTodoItems<T>(IQueryable<T> queryable, int? skip, int? batchSize)
        {
            throw new NotImplementedException();
        }

        public Task<TodoItem> GetTodoItem(string itemId)
        {
            throw new NotImplementedException();
        }

        public Task<TodoItem> GetTodoItemByState(string state, int? skip, int? batch)
        {
            throw new NotImplementedException();
        }

        public Task UpdateTodoItem(TodoItem existingTodoItem)
        {
            throw new NotImplementedException();
        }
    }
}
