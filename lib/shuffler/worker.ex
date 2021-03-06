defmodule Shuffler.Worker do
  @doc """
  Receive a list of words and a dictionary

  Returns a list of words shuffled with the dictionary

  ## Examples

    iex> Shuffler.Worker.run(["a"])
    ["a"]

    iex> Shuffler.Worker.run(["a"], %{"a" => ["a","@","4"]})
    ["a", "@", "4"]

    iex> Shuffler.Worker.run(["b"], %{"a" => ["@","4"]})
    ["b"]

    iex> Shuffler.Worker.run(["arma"], %{"a" => ["a","@","4"]})
    ["arma", "arm@", "arm4", "@rma", "@rm@", "@rm4", "4rma", "4rm@", "4rm4"]

    iex> Shuffler.Worker.run(["carro"], %{"c"=>["c","k"], "a"=>["a","@","4"], "o"=>["o","0"]})
    ["carro", "carr0", "c@rro", "c@rr0", "c4rro", "c4rr0", "karro", "karr0", "k@rro", "k@rr0", "k4rro", "k4rr0"]

    iex> Shuffler.Worker.run(["arma", "carro"], %{"c"=>["c","k"], "a"=>["a","@","4"], "o"=>["o","0"]})
    ["arma", "arm@", "arm4", "@rma", "@rm@", "@rm4", "4rma", "4rm@", "4rm4", "carro", "carr0", "c@rro", "c@rr0", "c4rro", "c4rr0", "karro", "karr0", "k@rro", "k@rr0", "k4rro", "k4rr0"]
  """
  def run(words, dictionary \\ %{}) do
    _words(words, [], dictionary)
  end

  @doc """
  Parallel version of Shuffler.Worker.run

  It creates a new process to shuffle each word provided.

  ## Examples

    iex> Shuffler.Worker.prun(["a"])
    ["a"]

    iex> Shuffler.Worker.prun(["a"], %{"a" => ["a","@","4"]})
    ["a", "@", "4"]

    iex> Shuffler.Worker.prun(["b"], %{"a" => ["@","4"]})
    ["b"]

    iex> Shuffler.Worker.prun(["arma"], %{"a" => ["a","@","4"]})
    ["arma", "arm@", "arm4", "@rma", "@rm@", "@rm4", "4rma", "4rm@", "4rm4"]

    iex> Shuffler.Worker.prun(["carro"], %{"c"=>["c","k"], "a"=>["a","@","4"], "o"=>["o","0"]})
    ["carro", "carr0", "c@rro", "c@rr0", "c4rro", "c4rr0", "karro", "karr0", "k@rro", "k@rr0", "k4rro", "k4rr0"]

    iex> Shuffler.Worker.prun(["arma", "carro"], %{"c"=>["c","k"], "a"=>["a","@","4"], "o"=>["o","0"]})
    ["arma", "arm@", "arm4", "@rma", "@rm@", "@rm4", "4rma", "4rm@", "4rm4", "carro", "carr0", "c@rro", "c@rr0", "c4rro", "c4rr0", "karro", "karr0", "k@rro", "k@rr0", "k4rro", "k4rr0"]
  """
  def prun(words, dictionary \\ %{}) do
    me = self
    words
    |> Enum.map(fn (word) ->
      spawn_link fn -> (send me, { self, _words([word], [], dictionary) }) end
    end)
    |> Enum.map(fn (pid) ->
      receive do { ^pid, result } -> result end
    end)
    |> List.flatten
  end

  defp _words([], acc, _dictionary), do: acc
  defp _words([head|tail], acc, dictionary) do
    _characters(String.codepoints(head), "", dictionary) ++
      _words(tail, acc, dictionary)
  end

  defp _characters([], acc, _dictionary), do: acc
  defp _characters([head|tail], acc, dictionary) do
    (dictionary[head] || [head])
    |> Enum.map(&(_characters(tail, acc <> &1, dictionary)))
    |> List.flatten
  end
end
