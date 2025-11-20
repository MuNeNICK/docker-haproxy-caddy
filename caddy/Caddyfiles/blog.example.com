blog.example.com {
	reverse_proxy <blog-server-ip>:<blog-server-port>

	tls {
	    on_demand
	}
}
