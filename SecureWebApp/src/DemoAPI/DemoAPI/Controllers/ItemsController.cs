using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using DemoAPI.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Logging;

namespace DemoAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ItemsController : ControllerBase
    {

        private CosmosClient cosmosClient;
        public ItemsController(CosmosClient db)
        {
            cosmosClient = db;
        }


        [HttpGet]
        public async Task<List<Item>> Get()
        {
            try
            {
                var database = this.cosmosClient.GetDatabase(Utils.Constants.DatabaseName);
                var container = database.GetContainer(Utils.Constants.ContainerName);


                var sqlQueryText = "SELECT * FROM c";
                QueryDefinition queryDefinition = new QueryDefinition(sqlQueryText);
                FeedIterator<Item> queryResultSetIterator = container.GetItemQueryIterator<Item>(queryDefinition);

                List<Item> items = new List<Item>();

                while (queryResultSetIterator.HasMoreResults)
                {
                    FeedResponse<Item> currentResultSet = await queryResultSetIterator.ReadNextAsync();
                    foreach (Item itm in currentResultSet)
                        items.Add(itm);
                }
                return items;
            }
            catch
            {
                return null;
            }
        }
    }
}
