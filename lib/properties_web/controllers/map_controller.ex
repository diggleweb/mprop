defmodule PropertiesWeb.MapController do
  use PropertiesWeb, :controller

  plug PropertiesWeb.Plugs.Brotli
  action_fallback PropertiesWeb.FallbackController


  def index(conn, _params) do
    render(conn, "index.html")
  end

  def geojson(conn, params) do
    {x_min, _} = params["southWestLongitude"]
            |> Float.parse()
    {y_min, _} = params["southWestLatitude"]
            |> Float.parse()
    {x_max, _} = params["northEastLongitude"]
            |> Float.parse()
    {y_max, _} = params["northEastLatitude"]
            |> Float.parse()

    layer = Map.get(params, "layer", "bike_lanes")
    # zoning = params["zoning"]
    # shapefiles = Properties.ShapeFile.list(x_min, y_min, x_max, y_max, zoning)
    if layer == "bike_lanes" do
      shapefiles = Properties.BikeShapeFile.list(x_min, y_min, x_max, y_max)
      render(conn, "bike_index.json", shapefiles: shapefiles)
    else
      shapefiles = Properties.ShapeFile.list_shapefiles_with_lead_service_lines(x_min, y_min, x_max, y_max)
      render(conn, "lead_index.json", shapefiles: shapefiles)
    end
    # shapefiles = Enum.map(shapefiles, fn(shapefile) ->
    #   cov = Properties.LandValue.adjacent_cov(shapefile.assessment)
    #   Map.put(shapefile, :adjacent_cov, cov)
    # end)

  end
end
