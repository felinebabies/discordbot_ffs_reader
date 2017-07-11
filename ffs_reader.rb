require 'bundler'
Bundler.require

require 'open_jtalk'

Dotenv.load

bot = Discordrb::Commands::CommandBot.new (
{
:token => ENV["DISCORD_TOKEN"],
:client_id => ENV["DISCORD_CLIENT_ID"],
:prefix => '!'
}
)

bot.command :hallo do |event|
 event.send_message("hallo,world.#{event.user.name}")
end

# 指定した話数を音声化して読み上げる
bot.command :ffs do |event, chapternum|
  chapternum = chapternum.to_i
  next "話数を数値で入力してください。" if chapternum == 0

  channel = event.user.voice_channel
  next "音声チャンネルに入室した状態で読み上げコマンドを実行してください" unless channel
  bot.voice_connect(channel)
  "Connected to voice channel: #{channel.name}"

  event.send_message("読み上げ話数：#{chapternum}")

  fnum = format("%05d", chapternum)
  fname = fnum + ".txt"
  mp3dir = "./ffsmp3"
  mp3name = "#{fnum}.mp3"
  mp3path = File.join(mp3dir, mp3name)
  text = File.open(File.join("./ffstext", fname)).read

  if(!File.exist?(mp3path)) then
    event.send_message("mp3を生成します:#{chapternum}")
    openjtalk = OpenJtalk.load(OpenJtalk::Config::Mei::NORMAL)
    header, data = openjtalk.synthesis(openjtalk.normalize_text(text))

    OpenJtalk::Mp3FileWriter.save(mp3path, header, data)
    openjtalk.close
  end

  voice_bot = event.voice
  voice_bot.play_file(mp3path)
end

bot.run
