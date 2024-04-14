#!/usr/bin/env node

const axios = require('axios');
const cheerio = require('cheerio');

const weatherIcons = {
  sunnyDay: '',
  clearNight: '望',
  cloudyFoggyDay: '',
  cloudyFoggyNight: '',
  rainyDay: '',
  rainyNight: '',
  snowyIcyDay: '',
  snowyIcyNight: '',
  severe: '',
  default: '',
};

const locationId = "ef8801feddd0b4136ac70c3b133451e22754037d3dbef11a91234d3442a9b7e6";

const url = `https://weather.com/ru-RU/weather/today/l/${locationId}`;
axios.get(url)
  .then(response => {
    const htmlData = cheerio.load(response.data);
    const temp = htmlData("span[data-testid='TemperatureValue']").eq(0).text();
    let status = htmlData("div[data-testid='wxPhrase']").text();
    status = status.length > 17 ? `${status.slice(0, 16)}..` : status;
    const statusCode = htmlData("#regionHeader").attr("class").split(" ")[2].split("-")[2];
    const icon = weatherIcons[statusCode] ? weatherIcons[statusCode] : weatherIcons.default;
    const tempFeel = htmlData("div[data-testid='FeelsLikeSection'] > span > span[data-testid='TemperatureValue']").text();
    const tempFeelText = `Как будто ${tempFeel}c`;
    const tempMin = htmlData("div[data-testid='wxData'] > span[data-testid='TemperatureValue']").eq(0).text();
    const tempMax = htmlData("div[data-testid='wxData'] > span[data-testid='TemperatureValue']").eq(1).text();
    const tempMinMax = `  ${tempMin}\t\t  ${tempMax}`;
    const windSpeed = htmlData("span[data-testid='Wind']").text().split("\n")[1];
    const windText = `煮  ${windSpeed}`;
    const humidity = htmlData("span[data-testid='PercentageValue']").text();
    const humidityText = `  ${humidity}`;
    const visibility = htmlData("span[data-testid='VisibilityValue']").text();
    const visibilityText = `  ${visibility}`;
    const airQualityIndex = htmlData("text[data-testid='DonutChartValue']").text();
    let prediction = htmlData("section[aria-label='Hourly Forecast']")
      .find("div[data-testid='SegmentPrecipPercentage'] > span")
      .text()
      .replace("Chance of Rain", "");
    prediction = prediction.length > 0 ? `\n\n    (hourly) ${prediction}` : prediction;
    const tooltipText = `\t\t<span size="xx-large">${temp}</span>\t\t\n<big>${icon}</big>\n<big>${status}</big>\n<small>${tempFeelText}</small>\n\n<big>${tempMinMax}</big>\n${windText}\t${humidityText}\n${visibilityText}\tИКВ ${airQualityIndex}\n<i>${prediction}</i>`;
    const outData = {
      text: `${icon}   ${temp}`,
      alt: status,
      tooltip: tooltipText,
      class: statusCode,
    }; console.log(JSON.stringify(outData));
  })
  .catch(error => {
    console.error("Error fetching weather data:", error);
  });
