defmodule ScheduleWebWeb.PeopleLive.Index do
  use Phoenix.LiveView
  alias Schedule.Repo
  alias Schedule.Person
  alias Schedule.Recordings
  alias ScheduleWebWeb.PeopleView
  alias ScheduleWebWeb.Router.Helpers, as: Routes

  def mount(_session, socket) do
    people = Repo.all(Person)
    {:ok, assign(socket, people: people,
        weekday_id: nil,
        reserve_id: nil,
        month: nil
      )}
  end

  def render(assigns) do
    PeopleView.render("index.html", assigns)
  end

  def handle_event("update_month", %{"month"=> month}, socket) do
    IO.puts "this month is #{month}"
    {:noreply, assign(socket, month: month)}
  end

  def handle_event("reset_month",_ , socket) do
    case Recordings.reset_all_reserve() do
      {_, _term } ->
        {:stop,
         socket
         |> put_flash(:info, "all reserved are reset successfully")
         |> redirect(to: Routes.people_path(socket, :index))}
      {_, nil} ->
        {:noreply, socket}
    end
  end



  def handle_event("weekday" <> person_id, _, socket) do
    person_id = String.to_integer(person_id)
    changeset = socket.assigns.people
    |> Enum.find(&(&1.doctor_id == person_id))
    |> Recordings.change_person()
    |> Map.put(:action, :update)
    {:noreply, assign(socket, changeset: changeset, weekday_id: person_id)}
  end


  def handle_event("reserve" <> person_id, _, socket) do
    person_id = String.to_integer(person_id)
    changeset = socket.assigns.people
    |> Enum.find(&(&1.doctor_id == person_id))
    |> Recordings.change_person()
    |> Map.put(:action, :update)
    {:noreply, assign(socket, changeset: changeset, reserve_id: person_id)}
  end


  def handle_event("save_wk_day", %{"id" => person_id, "person" => person_params}, socket) do
    person_id = String.to_integer(person_id)
    person = Enum.find(socket.assigns.people, &(&1.doctor_id == person_id))
    case Recordings.update_weekday(person, person_params) do
      {:ok, _person} ->
        {:stop,
         socket
         |> put_flash(:info, "Week day updated successfully")
         |> redirect(to: Routes.people_path(socket, :index))}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end


  def handle_event("save_reserve", %{"id" => person_id, "person" => person_params}, socket) do
    person_id = String.to_integer(person_id)
    person = Enum.find(socket.assigns.people, &(&1.doctor_id == person_id))
    case Recordings.update_reserve(person, person_params, socket.assigns.month) do
      {:ok, _person} ->
        {:stop,
         socket
         |> put_flash(:info, "Reserve Days updated successfully")
         |> redirect(to: Routes.people_path(socket, :index))}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end


end
