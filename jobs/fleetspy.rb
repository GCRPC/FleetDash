require 'mysql2'

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '15s', :first_in => 0 do |job|
	db = Mysql2::Client.new( :host => "192.168.1.105", :username => "dbmojo", :password => "igotmojo", :port => 3306, :database => "busavl" )  

	sql = "SELECT * FROM last_location WHERE TIMESTAMPDIFF(second,date,NOW()) < 15 ORDER BY unit;"

	results = db.query(sql,:as => :hash)

	hrows = [
		{ cols: [ #{value: 'ID'},
		{value: 'Bus Number'},
		{value: 'Latitude'},
		{value: 'Longitude'},
		{value: 'Speed'},
		{value: 'Heading'},
		#{value: 'Date'},
		] }
	]

	ary = Array.new
	results.each do |row|

		dir = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW']

		rows = { cols: [ #{value: "#{row['idlast_location']}"},
			{value: "#{row['unit']}"},
			{value: "#{row['lat']}"},
			{value: "#{row['lon']}"},
			{value: (("#{row['speed']}".to_i).round).to_s + " MPH"},
			{value: dir[("#{row['heading']}".to_i / 22.5 % 16).round]},
			#{value: "#{row['date']}"}
		] }
		ary.push(rows)
	end
	
	send_event('account_count', { hrows: hrows, rows: ary } )
end
