# -*- coding: utf-8 -*-

Plugin.create :Mikutter_HaikuPost do
UserConfig[:Mikutter_HaikuPost] ||= []
  
  @@err = 0
  @@hatena_id = UserConfig[:hatena_id]
  if @@hatena_id=='' then
    @@err = 1
  end
  @@hatena_api_pass = UserConfig[:hatena_api_pass]
  if @@hatena_api_pass=='' then
    @@err = 1
  end
  
  def postToHaiku(message)
	res = Net::HTTP.post_form(
		URI.parse("http://#{@@hatena_id}:#{@@hatena_api_pass}@h.hatena.ne.jp/api/statuses/update.json"),
		{'keyword'=>"id:#{@@hatena_id}", 'status'=>message, 'source'=>'Mikutter-HaikuPost'}
	)
  end

  settings("はてなハイク") do
    input("はてなID",:hatena_id)
    input("APIパスワード",:hatena_api_pass)
    boolean("Twitterにも同時に投稿する", :do_multi_post)
  end

  command(:post_to_haiku,
  		name: 'ハイクに投稿する',
  		condition: lambda{ |opt| true },
  		visible: true,
  		role: :postbox) do |opt|
	begin
		if @@err==1 then
			Gtk::Dialog.alert("設定画面でIDとかパスワードを設定してください('ω`)")
		else
			message = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
			postToHaiku(message)
			defactivity "Haiku_post", "Haiku_Post"
			activity :Haiku_Post, "たぶん投稿した。"
			Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
		end
	end
  end
  command(:post_to_haiku_and_twitter,
  		name: 'ハイクとTwitter両方に投稿する',
  		condition: lambda{ |opt| true },
  		visible: true,
  		role: :postbox) do |opt|
	begin
		if @@err==1 then
			Gtk::Dialog.alert("設定画面でIDとかパスワードを設定してください('ω`)")
		else
			message = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
			Service.primary.update(:message => message)
			postToHaiku(message)
			defactivity "Haiku_post", "Haiku_Post"
			activity :Haiku_Post, "たぶん投稿した。"
			Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
		end
	end
  end

end