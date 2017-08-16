using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
// Json Library
using Newtonsoft.Json;
using Newtonsoft.Json.Bson;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json.Schema;
using Newtonsoft.Json.Serialization;


namespace WindowsFormsApplication2
{
    public class JsonObject
    {
        public String InString { get; set; }
        public JObject OutObject { get; set; }
        public JsonException JsonEx;
        public void ParseJson()
        {
            try
            {
                OutObject = JObject.Parse(InString);
            }
            catch (JsonException JsonError)
            {
                JsonEx = JsonError;
            }
        }
    }
    public class JsonParseResults
    {
        public string Name { get; set; }
        public string Value { get; set; }
        public string Type{ get; set; }
        public string path { get; set; }
        public JsonParseResults()
        {

        }
    }

    public class ParseJsonObject
    {
        public string Name;
        public JToken Data;
        public List<JsonParseResults> Results = new List<JsonParseResults>();
        public JsonParseResults R { get; set; }
        public List<JsonParseResults> JObjectParse(JObject JsonObj)
        {
            IEnumerable<String> Paths = JsonObj.DescendantsAndSelf().Where(y=>y.HasValues).Select(x=>x.Path).Distinct();
            foreach (string P in Paths)
            {
                R = new JsonParseResults();
                JToken SelectedToken = JsonObj.SelectToken(P);
                string type = SelectedToken.Type.ToString();
                R.path = P;
                R.Type = type;
                R = HandleType(SelectedToken,R.Type);

                Results.Add(R);
            }
            return Results;
        }
        public JsonParseResults HandleType(JToken SelectedToken, string type)
        {
            type = type.ToLower();
            switch (type)
            {
                case "string":
                    try
                    {
                        R.Name = R.path.Substring(R.path.LastIndexOf('.')+1);
                    }
                    catch 
                    {
                        R.Name = R.path;
                    }
                    R.Value = SelectedToken.ToString();
                    break;
                case "object":
                case "array":
                    foreach (var AV in SelectedToken.Values())
                    {
                        foreach (JToken JT in AV.Values().ToList())
                        {
                            HandleType(JT,JT.Type.ToString());
                        }   
                    }
                    break;
            }
            return R;
        }
    }

}
