using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Todo.Api.Common.DTOs
{
    public record CreateUpdateTodoItemDTO(string name, string state, DateTimeOffset? dueDate, DateTimeOffset? completedDate, string? description = null);
}
