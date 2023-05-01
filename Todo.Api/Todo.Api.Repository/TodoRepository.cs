using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Linq;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
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
        private readonly CosmosClient _cosmosClient;
        private readonly Container _todoItemContainer;
        private readonly IConfiguration _configuration;
        private readonly ILogger<TodoRepository> _logger;

        public TodoRepository(CosmosClient cosmosClient, IConfiguration configuration, ILogger<TodoRepository> logger)
        {
            _configuration = configuration;
            _logger = logger;
            _cosmosClient = cosmosClient;
            _todoItemContainer = _cosmosClient.GetContainer(_configuration["DATABASE_NAME"], _configuration["CONTAINER_NAME"]);
        }

        public async Task AddItem(TodoItem item)
        {
            try
            {
                item.Id = Guid.NewGuid().ToString();
                ItemRequestOptions itemRequestOptions = new ItemRequestOptions { EnableContentResponseOnWrite = false };
                await _todoItemContainer.CreateItemAsync(item, new PartitionKey(item.Id),itemRequestOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(AddItem)}: {ex.Message}");
                throw;
            }
        }

        public async Task DeleteTodoItem(string itemId)
        {
            try
            {
                await _todoItemContainer.DeleteItemAsync<TodoItem>(itemId, new PartitionKey(itemId));
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(DeleteTodoItem)}: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TodoItem>> GetAllTodoItems(int? skip, int? batchSize)
        {
            try
            {
                return await ToListAsync(
                    _todoItemContainer.GetItemLinqQueryable<TodoItem>(),
                    skip,
                    batchSize);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(GetAllTodoItems)}: {ex.Message}");
                throw;
            }
        }

        public async Task<TodoItem> GetTodoItem(string itemId)
        {
            try
            {
                var todoItemResponse = await _todoItemContainer.ReadItemAsync<TodoItem>(itemId, new PartitionKey(itemId));
                return todoItemResponse;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(GetTodoItem)}: {ex.Message}");
                throw;
            }
        }

        public async Task<IEnumerable<TodoItem>> GetTodoItemsByState(string state, int? skip, int? batch)
        {
            try
            {
                return await ToListAsync(
                    _todoItemContainer.GetItemLinqQueryable<TodoItem>().Where(i => i.State == state),
                    skip,
                    batch);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(GetTodoItemsByState)}: {ex.Message}");
                throw;
            }
        }

        public async Task UpdateTodoItem(TodoItem existingTodoItem)
        {
            try
            {
                await _todoItemContainer.ReplaceItemAsync(existingTodoItem, existingTodoItem.Id, new PartitionKey(existingTodoItem.Id));
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(UpdateTodoItem)}: {ex.Message}");
                throw;
            }
        }

        private async Task<List<T>> ToListAsync<T>(IQueryable<T> queryable, int? skip, int? batchSize)
        {
            if (skip is not null)
            {
                queryable = queryable.Skip(skip.Value);
            }

            if (batchSize is not null)
            {
                queryable = queryable.Take(batchSize.Value);
            }

            using FeedIterator<T> iterator = queryable.ToFeedIterator();
            var items = new List<T>();

            while (iterator.HasMoreResults)
            {
                foreach (var item in await iterator.ReadNextAsync())
                {
                    items.Add(item);
                }
            }

            return items;
        }
    }
}
