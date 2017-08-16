using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WindowsFormsApplication3
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            RichTextBox RTB = new RichTextBox();
            Button BTN = new Button();
            ContainerControl CC = new ContainerControl();
            CC.Location = new Point(0, 0);
            RTB.Location = new Point(0, Bottom);
            BTN.Location = new Point(Right, Top);

            CC.Height = 500;
            CC.Width = 500;

            BTN.AutoSize = true;
            BTN.Text = "Test Json";
            BTN.Click += (sender, EventArgs) => { BTN_Json(sender, EventArgs, RTB); };

            RTB.Width = CC.Width;
            RTB.Height = CC.Height / 2;
            RTB.Text = "JsonValuesHere";
            RTB.Name = "JsonUserInput";

            this.AutoSize = true;

            this.Controls.Add(CC);

            CC.Controls.Add(RTB);
            CC.Controls.Add(BTN);

            InitializeComponent();
        }

        private void BTN_Json(Object sender, EventArgs e, RichTextBox EVT_RTB)
        {
            ParseJsonObject PJO = new ParseJsonObject();
            JsonObject JO = new JsonObject();
            JO.InString = EVT_RTB.Text;
            JO.ParseJson();
            if (JO.JsonEx != null)
            {
                Console.Write(JO.JsonEx.Message);
            }
            else
            {
                List<JsonParseResults> ResultsList = PJO.JObjectParse(JO.OutObject);
                foreach (JsonParseResults JPR in ResultsList)
                {
                    Console.Write("-Name- {0} -Value- {1} -Path- {2}\r\n", JPR.Name, JPR.Value, JPR.path);
                }
            }
        }
    }
}
