import { Atp45Result } from './../api/models/atp-45-result';
import { GeoJsonSliceResponse } from './../api/models/geo-json-slice-response';
import { Injectable } from '@angular/core';
import { MapPlot, PlotType } from '../models/map-plot';
import { MapService } from './map.service';
import { Feature, FeatureCollection } from 'geojson';
import { ColorbarData } from '../api/models';
import { circle, circleMarker, FeatureGroup, geoJSON, LayerGroup } from 'leaflet';
import parseGeoraster from 'georaster';
import GeoRasterLayer from 'georaster-layer-for-leaflet';
import chroma from 'chroma-js';


const POINT_MARKER_OPTIONS = {
  radius: 2,
  fillColor: "black",
  color: "black",
  weight: 1,
  opacity: 1,
  fillOpacity: 1
};

const REL_LOC_MARKER_OPTIONS = {
  radius: 5,
  fillColor: "red",
  color: "red",
  weight: 4,
  opacity: 1,
  fillOpacity: 1
};

function getColor(value: number, colorbar: ColorbarData) {
  let ticks = colorbar.ticks as number[];
  let colors = colorbar!.colors as string[];
  let n = ticks.length;
  if (value <= ticks[0]) {
    return colors[0];
  }
  for (let i = 1; i < n; i++) {
    if (value <= ticks[i]) {
      return colors[i - 1];
    }
  }
  return colors[n - 2];
}

@Injectable({
  providedIn: 'root'
})
export class MapPlotsService {

  constructor(
    private mapService: MapService,
  ) { }

  fillPlotGeoJSON(plotData: Atp45Result | GeoJsonSliceResponse, type: PlotType) {
    let newPlot = new MapPlot(type);

    newPlot.metadata = plotData.metadata
    newPlot.geojson = plotData.collection as FeatureCollection;
    return newPlot;
  }

  async fillPlotTiff(plotData: Blob, type: PlotType) {
    const arrayBuffer = await plotData.arrayBuffer()
    const geoRaster = await parseGeoraster(arrayBuffer);
    let newPlot = new MapPlot(type);
    console.log(geoRaster);
    newPlot.data = geoRaster;
    newPlot.metadata = this._colorbarFromGeoRaster(geoRaster)
    return newPlot
  }

  addTiff(geoRaster: any) {
    console.log(geoRaster)

    // inspired from https://github.com/GeoTIFF/georaster-layer-for-leaflet-example/blob/master/examples/color-scale.html
    const min = geoRaster.mins[0];
    const max = geoRaster.maxs[0];
    const range = geoRaster.ranges[0];
    let scale = this._colorScale()
    const imageryLayer = new GeoRasterLayer({
      georaster: geoRaster,
      pixelValuesToColorFn: pixelValues => {
        let pixelValue = pixelValues[0]; // there's just one band in this raster

        if (pixelValue === 0) return "";
        // console.log("nir:", nir);
        let scaledPixelValue = (pixelValue - min) / range;
        let color = scale(scaledPixelValue).hex();

        return color;
      },
      resolution: 64,
      opacity: 0.8
    });

    return imageryLayer as typeof GeoRasterLayer;
  }

  _colorScale() {
    return chroma.scale("Spectral").domain([1,0]);
  }

  _colorbarFromGeoRaster(geoRaster: any, length = 10): ColorbarData {
    const min: number = geoRaster.mins[0];
    const max: number = geoRaster.maxs[0];
    const range = geoRaster.ranges[0];
    let scale = this._colorScale().domain([max, min]);
    let ticks: number[] = [];
    let colors: string[] = [];
    let step = range / (length - 1);
    for (let i = 0; i < length; i++) {
      let tick = min + (step * i)
      ticks.push(tick);
      colors.push(scale(tick).hex())
    }
    colors.shift()
    return {
      colors,
      ticks
    };
  }

  setColors(layers: LayerGroup, colorbar: ColorbarData) {
    layers.eachLayer((layer: any) => {
      let val = layer.feature.properties.val;
      if (val !== undefined) {
        layer.setStyle({
          color: getColor(val, colorbar),
        });
      }
    });
  }

  flexpartPlotToLayer(collection: FeatureCollection) {
    // let options: L.GeoJSONOptions = {
    //     pointToLayer: function (feature: any, latlng: L.LatLng) {
    //         if (feature.properties.type === "releasePoint") {
    //             return circleMarker(latlng, REL_LOC_MARKER_OPTIONS);
    //         }
    //         return circleMarker(latlng, POINT_MARKER_OPTIONS);
    //     },
    //     style: (feature: any) => {
    //         let options: L.PathOptions = {
    //             stroke: false,
    //             fillOpacity: 0.4,
    //         }
    //         options = feature.properties ? {...options, color: feature.properties.color } : options
    //         return options;
    //     },
    // };

    let layers = geoJSON(undefined, {
      pmIgnore: true
    });

    layers.addData(collection as FeatureCollection);
    return layers;
  }

  atp45PlotToLayer(collection: FeatureCollection) {
    let options: L.GeoJSONOptions = {
      pointToLayer: function (feature: any, latlng: L.LatLng) {
        if (feature.properties.type === "releasePoint") {
          return circleMarker(latlng, REL_LOC_MARKER_OPTIONS);
        }
        return circleMarker(latlng, POINT_MARKER_OPTIONS);
      },
      style: (feature: any) => {
        let options: L.PathOptions = {
          // stroke: false,
          fillOpacity: 0.4,
        }
        options = feature.properties.type == "release" ? { ...options, color: "red" } : options
        return options;
      },
    };
    let geojson = geoJSON(undefined, {
      pmIgnore: true,
      ...options
    });
    let featureGroup = new FeatureGroup()
    geojson.addData(collection as FeatureCollection);
    featureGroup.addLayer(geojson)
    // return layers as LayerGroup
    return featureGroup
  }


  createMapPlotGeoJSON({ type, plotData }: any) {
    let mapPlot = this.fillPlotGeoJSON(plotData, type)
    return mapPlot;
  }

  createMapPlotTiff({ type, plotData }: any) {
    let mapPlot = this.fillPlotTiff(plotData, type)
    return mapPlot;
  }
}
