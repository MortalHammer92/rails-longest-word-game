require "open-uri"
require "json"

class GamesController < ApplicationController
  def new
    # 10 lettres au hasard
    @letters = 10.times.map { ("A".."Z").to_a.sample }
    # ➕ le total, pour l'afficher aussi sur la page de jeu (0 au tout début)
    @total_score = session[:total_score] || 0
  end

  def score
    # lire le mot et la grille envoyés par le formulaire
    @word = params[:word].upcase
    @letters = params[:letters].split(" ")

    # scénario 1 : le mot peut-il être construit avec la grille ?
    @in_grid = @word.chars.all? { |letter| @word.count(letter) <= @letters.count(letter) }

    # scénario 2 : est-ce un vrai mot anglais ?
    url = "https://dictionary.lewagon.com/#{@word}"
    data = JSON.parse(URI.open(url).read)
    @english_word = data["found"]

    # ➕ le score de CETTE partie : nombre de lettres si le mot est valide, sinon 0
    @score = if @in_grid && @english_word
               @word.length
    else
               0
    end

    # ➕ le total, gardé dans la session d'une partie à l'autre
    session[:total_score] ||= 0              # la toute première fois, partir de 0
    session[:total_score] += @score          # ajouter le score de cette partie
    @total_score = session[:total_score]     # pour l'afficher dans la vue
  end
end
