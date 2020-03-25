using Newtonsoft.Json;
namespace DemoAPI.Models
{
    public class Item
    {
        [JsonProperty(PropertyName = "id")]
        public string Id { get; set; }

        public string Name { get; set; }

        public string Partition { get; set; } = "All";

    }
}
