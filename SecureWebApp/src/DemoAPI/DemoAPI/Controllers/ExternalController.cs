using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace DemoAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ExternalController : ControllerBase
    {
        private IConfiguration config;
        public ExternalController(IConfiguration configuration)
        {
            this.config = configuration;
        }

        [HttpGet]
        public async Task<string> Get()
        {
            HttpClient client = new HttpClient();
            var response = await client.GetStringAsync(this.config["ExternalEndpoint"]);
            return response;
        }
    }
}
