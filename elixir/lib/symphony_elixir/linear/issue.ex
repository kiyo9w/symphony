defmodule SymphonyElixir.Linear.Issue do
  @moduledoc """
  Normalized Linear issue representation used by the orchestrator.
  """

  defstruct [
    :id,
    :identifier,
    :title,
    :description,
    :priority,
    :state,
    :state_type,
    :branch_name,
    :url,
    :assignee_id,
    blocked_by: [],
    labels: [],
    assigned_to_worker: true,
    created_at: nil,
    updated_at: nil
  ]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          identifier: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          priority: integer() | nil,
          state: String.t() | nil,
          state_type: String.t() | nil,
          branch_name: String.t() | nil,
          url: String.t() | nil,
          assignee_id: String.t() | nil,
          labels: [String.t()],
          assigned_to_worker: boolean(),
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @spec label_names(t()) :: [String.t()]
  def label_names(%__MODULE__{labels: labels}) do
    labels
  end

  @spec continuation_active?(t(), [String.t()], [String.t()]) :: boolean()
  def continuation_active?(%__MODULE__{} = issue, active_states, terminal_states)
      when is_list(active_states) and is_list(terminal_states) do
    active_state_names =
      active_states
      |> Enum.map(&normalize/1)
      |> Enum.filter(&(&1 != ""))
      |> MapSet.new()

    terminal_state_names =
      terminal_states
      |> Enum.map(&normalize/1)
      |> Enum.filter(&(&1 != ""))
      |> MapSet.new()

    continuation_active_with_sets?(issue, active_state_names, terminal_state_names)
  end

  def continuation_active?(_issue, _active_states, _terminal_states), do: false

  defp continuation_active_with_sets?(
         %__MODULE__{state: state_name, state_type: state_type},
         active_state_names,
         terminal_state_names
       ) do
    normalized_state = normalize(state_name)

    cond do
      normalized_state == "" ->
        false

      MapSet.member?(terminal_state_names, normalized_state) ->
        false

      not MapSet.member?(active_state_names, normalized_state) ->
        false

      is_binary(state_type) and normalize(state_type) != "" ->
        normalize(state_type) == "started"

      true ->
        normalized_state != "todo"
    end
  end

  defp normalize(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
  end

  defp normalize(_value), do: ""
end
