using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Todo.Api.Common;
using Todo.Api.Common.DTOs;
using Todo.Api.Repository.Interfaces;

namespace Todo.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TodoController : ControllerBase
    {
        private readonly ITodoRepository _todoRepository;
        private readonly ILogger<TodoController> _logger;

        public TodoController(ILogger<TodoController> logger, ITodoRepository todoRepository)
        {
            _todoRepository = todoRepository;
            _logger = logger;
        }

        [HttpPost]
        [ProducesResponseType(StatusCodes.Status201Created)]
        public async Task<IActionResult> CreateTodoItem([FromBody] CreateUpdateTodoItemDTO todoItem)
        {
            var todo = new TodoItem
            {
                Name = todoItem.name,
                State = todoItem.state,
                DueDate = todoItem.dueDate,
                CompletedDate = todoItem.completedDate,
                Description = todoItem.description,
            };

            await _todoRepository.AddItem(todo);

            return CreatedAtAction(nameof(CreateTodoItem), todo);
        }
    }
}
