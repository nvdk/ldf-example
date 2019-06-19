defmodule Dispatcher do
  use Plug.Router

  def start(_argv) do
    port = 80
    IO.puts "Starting Plug with Cowboy on port #{port}"
    Plug.Adapters.Cowboy.http __MODULE__, [], port: port
    :timer.sleep(:infinity)
  end

  plug Plug.Logger
  plug :match
  plug :dispatch

  # In order to forward the 'themes' resource to the
  # resource service, use the following forward rule.
  #
  # docker-compose stop; docker-compose rm; docker-compose up
  # after altering this file.
  #
  # match "/themes/*path" do
  #   Proxy.forward conn, path, "http://resource/themes/"
  # end

  options _ do
    send_resp( conn, 200, "Option calls are accepted by default." )
  end

  match "/bestuurseenheden/*path" do
    Proxy.forward conn, path, "http://cache/bestuurseenheden/"
  end
  match "/werkingsgebieden/*path" do
    Proxy.forward conn, path, "http://cache/werkingsgebieden/"
  end
  match "/bestuurseenheid-classificatie-codes/*path" do
    Proxy.forward conn, path, "http://cache/bestuurseenheid-classificatie-codes/"
  end
  match "/bestuursorganen/*path" do
    Proxy.forward conn, path, "http://cache/bestuursorganen/"
  end
  match "/bestuursorgaan-classificatie-codes/*path" do
    Proxy.forward conn, path, "http://cache/bestuursorgaan-classificatie-codes/"
  end
  match "/entiteiten/*path" do
    Proxy.forward conn, path, "http://cache/entiteiten/"
  end
  match "/fracties/*path" do
    Proxy.forward conn, path, "http://cache/fracties/"
  end
  match "/fractietypes/*path" do
    Proxy.forward conn, path, "http://cache/fractietypes/"
  end
  match "/geboortes/*path" do
    Proxy.forward conn, path, "http://cache/geboortes/"
  end
  match "/lijsttypes/*path" do
    Proxy.forward conn, path, "http://cache/lijsttypes/"
  end
  match "/kandidatenlijsten/*path" do
    Proxy.forward conn, path, "http://cache/kandidatenlijsten/"
  end
  match "/lidmaatschappen/*path" do
    Proxy.forward conn, path, "http://cache/lidmaatschappen/"
  end
  match "/mandaten/*path" do
    Proxy.forward conn, path, "http://cache/mandaten/"
  end
  match "/bestuursfunctie-codes/*path" do
    Proxy.forward conn, path, "http://cache/bestuursfunctie-codes/"
  end
  match "/mandatarissen/*path" do
    Proxy.forward conn, path, "http://cache/mandatarissen/"
  end
  match "/mandataris-status-codes/*path" do
    Proxy.forward conn, path, "http://cache/mandataris-status-codes/"
  end
  match "/beleidsdomein-codes/*path" do
    Proxy.forward conn, path, "http://cache/beleidsdomein-codes/"
  end
  match "/personen/*path" do
    Proxy.forward conn, path, "http://cache/personen/"
  end
  match "/geslacht-codes/*path" do
    Proxy.forward conn, path, "http://cache/geslacht-codes/"
  end
  match "/identificatoren/*path" do
    Proxy.forward conn, path, "http://cache/identificatoren/"
  end
  match "/rechtsgronden-aanstelling/*path" do
    Proxy.forward conn, path, "http://cache/rechtsgronden-aanstelling/"
  end
  match "/rechtsgronden-beeindiging/*path" do
    Proxy.forward conn, path, "http://cache/rechtsgronden-beeindiging/"
  end
  match "/rechtstreekse-verkiezingen/*path" do
    Proxy.forward conn, path, "http://cache/rechtstreekse-verkiezingen/"
  end
  match "/rechtsgronden/*path" do
    Proxy.forward conn, path, "http://cache/rechtsgronden/"
  end
  match "/tijdsgebonden-entiteiten/*path" do
    Proxy.forward conn, path, "http://cache/tijdsgebonden-entiteiten/"
  end
  match "/tijdsintervallen/*path" do
    Proxy.forward conn, path, "http://cache/tijdsintervallen/"
  end
  match "/verkiezingsresultaten/*path" do
    Proxy.forward conn, path, "http://cache/verkiezingsresultaten/"
  end
  match "/verkiezingsresultaat-gevolg-codes/*path" do
    Proxy.forward conn, path, "http://cache/verkiezingsresultaat-gevolg-codes/"
  end
  match "/vestigingen/*path" do
    Proxy.forward conn, path, "http://cache/vestigingen/"
  end
  match "/contact-punten/*path" do
    Proxy.forward conn, path, "http://cache/contact-punten/"
  end
  match "/posities/*path" do
    Proxy.forward conn, path, "http://cache/posities/"
  end
  match "/rollen/*path" do
    Proxy.forward conn, path, "http://cache/rollen/"
  end
  match "/organisaties/*path" do
    Proxy.forward conn, path, "http://cache/organisaties/"
  end
  match "/files/*path" do
    Proxy.forward conn, path, "http://filehost/"
  end
  get "/exports/*path" do
    # we bypass the cache on purpose since mu-cl-resources is not the master of the exports
    Proxy.forward conn, path, "http://resource/exports/"
  end
  get "/sitemap.xml" do
    Proxy.forward conn, [], "http://sitemap/sitemap.xml"
  end

  match "/ldf/*path" do
    forwarded_for_host =
      conn
      |> Plug.Conn.get_req_header("x-forwarded-for")
      |> Enum.at(0)

    conn
    |> Plug.Conn.delete_req_header("host")
    |> Plug.Conn.put_req_header("host", forwarded_for_host)
    |> Map.put(:host, forwarded_for_host)
    |> Proxy.forward(path, "http://ldf:3000/ldf/")
  end
  match _ do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end

  def put_new_key( list, key, value ) do
    # Adds the key/value tuple to the list, unless it is already there

    if List.keymember?( list, key, 0 ) do
      list
    else
      [ { key, value } | list ]
    end
  end

end
