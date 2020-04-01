using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using DemoAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Cosmos;

namespace DemoAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PopulateController : ControllerBase
    {
        private CosmosClient cosmosClient;
        public PopulateController(CosmosClient db)
        {
            cosmosClient = db;
        }

        [HttpGet]
        public async Task<string> Get()
        {
            try
            {
                Database database = await this.cosmosClient.CreateDatabaseIfNotExistsAsync(Utils.Constants.DatabaseName);
                Container container = await database.CreateContainerIfNotExistsAsync(Utils.Constants.ContainerName, "/Partition", 400);

                List<Item> itms = new List<Item>()
                {
                    new Item {Id = "1", Name = "Item1" },
                    new Item {Id = "2", Name = "Item2" },
                    new Item {Id = "3", Name = "Item3" },
                    new Item {Id = "4", Name = "Item4" },
                    new Item {Id = "5", Name = "Item5" },
                };

                foreach(var itm in itms)
                    await container.CreateItemAsync<Item>(itm, new PartitionKey(itm.Partition));

                
                return "5 items added to database";
            }
            catch (Exception ex)
            {
                return $"Error occurred {ex.Message}";
            }
        }
    }
}
