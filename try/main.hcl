disable_mlock = true
ui = true
# log_level = "Debug"
api_addr = "http://127.0.0.1:8200"

listener "tcp" {  
    address = "127.0.0.1:8200"
    tls_disable = true
}

storage "raft" {
    path    = "/tmp/vault/file/raft"
    node_id = "raft_node_1"
}

cluster_addr = "http://127.0.0.1:8201"
