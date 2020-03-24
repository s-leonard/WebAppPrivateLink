using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace DemoAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ExternalController : ControllerBase
    {
      
        public ExternalController()
        {
        }

        [HttpGet]
        public async Task<string> Get()
        {
            HttpClient client = new HttpClient();
            var response = await client.GetStringAsync("https://raw.githubusercontent.com/s-leonard/WebAppPrivateLink/master/README.md");
            return response;
        }
    }
}
