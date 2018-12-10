bench:
	# Warmup
	# Baseline
	ab -c 2 -n 3 https://69sgjkx4e0.execute-api.us-east-2.amazonaws.com/dev
	ab -c 2 -n 3 https://kvverflq1a.execute-api.us-east-2.amazonaws.com/dev
	# A
	ab -c 2 -n 3 https://d8ua4jrr82.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 3 https://uvrof4qhjb.execute-api.us-east-2.amazonaws.com/Prod
	# D
	ab -c 2 -n 3 https://27nex4iys7.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 3 https://elha5ztbse.execute-api.us-east-2.amazonaws.com/Prod
	# E
	ab -c 2 -n 3 https://ga4uqeibxb.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 3 https://qw2t6ao82c.execute-api.us-east-2.amazonaws.com/Prod
	# F
	ab -c 2 -n 3 https://leosblcqf8.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 3 https://4j13b914q4.execute-api.us-east-2.amazonaws.com/Prod
	# G
	ab -c 2 -n 3 https://52ndy2s1ah.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 3 https://g9fzxul00f.execute-api.us-east-2.amazonaws.com/Prod
	# H
	ab -c 2 -n 3 https://1o7ekig6f4.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 3 https://8103l7sz52.execute-api.us-east-2.amazonaws.com/Prod

	# Wait 5 minutes to ease calculating averages on Cloudwatch
	sleep 300

	# Bench
	# Baseline
	ab -c 2 -n 200 https://69sgjkx4e0.execute-api.us-east-2.amazonaws.com/dev
	ab -c 2 -n 200 https://kvverflq1a.execute-api.us-east-2.amazonaws.com/dev
	# A
	ab -c 2 -n 200 https://d8ua4jrr82.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 200 https://uvrof4qhjb.execute-api.us-east-2.amazonaws.com/Prod
	# D
	ab -c 2 -n 200 https://27nex4iys7.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 200 https://elha5ztbse.execute-api.us-east-2.amazonaws.com/Prod
	# E
	ab -c 2 -n 200 https://ga4uqeibxb.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 200 https://qw2t6ao82c.execute-api.us-east-2.amazonaws.com/Prod
	# F
	ab -c 2 -n 200 https://leosblcqf8.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 200 https://4j13b914q4.execute-api.us-east-2.amazonaws.com/Prod
	# G
	ab -c 2 -n 200 https://52ndy2s1ah.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 200 https://g9fzxul00f.execute-api.us-east-2.amazonaws.com/Prod
	# H
	ab -c 2 -n 200 https://1o7ekig6f4.execute-api.us-east-2.amazonaws.com/Prod
	ab -c 2 -n 200 https://8103l7sz52.execute-api.us-east-2.amazonaws.com/Prod
