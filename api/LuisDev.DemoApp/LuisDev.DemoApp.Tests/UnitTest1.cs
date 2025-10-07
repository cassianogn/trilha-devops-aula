using LuisDev.DemoApp.Controllers;

namespace LuisDev.DemoApp.Tests
{
    public class UnitTest1
    {
        [Fact]
        public void Test1()
        {
            var test = new WeatherForecastController();
            test.Get();
            Assert.True(true);
        }
    }
}