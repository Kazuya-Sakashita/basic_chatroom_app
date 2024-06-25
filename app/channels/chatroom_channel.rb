class ChatroomChannel < ApplicationCable::Channel
  def subscribed
    # chatroom_channelからのストリーミングを開始する
    stream_from 'chatroom_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # クライアントがメッセージ送信に使うメソッド
  def talk(data)
    # デバッグ用ログ
    Rails.logger.debug "Received data: #{data.inspect}"

    # クライアントからのデータをもとにmessageモデルを組み立てる（現在日時を使用）
    message = Message.new
    message.published = Time.now
    message.sender = data['data']['sender']
    message.content = data['data']['content']

    # デバッグ用ログ
    Rails.logger.debug "Constructed message: #{message.inspect}"

    # メッセージをデータベースに保存し、有効であればブロードキャスト
    if message.save
      ActionCable.server.broadcast 'chatroom_channel',
        { message: render_message(message) }
    else
      # メッセージが無効な場合の処理を追加（オプション）
      ActionCable.server.broadcast 'chatroom_channel',
        { error: "Invalid message" }
    end
  end

  private

  # Messageモデルをレンダリングするプライベートメソッド
  def render_message(message)
    ApplicationController.renderer.render(partial: 'messages/message',
      locals: { message: message })
  end
end
