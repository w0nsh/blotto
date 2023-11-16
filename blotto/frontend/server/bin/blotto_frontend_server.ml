let () =
  Command_unix.run
    ~version:"1.0"
    ~build_info:"RWO"
    Blotto_frontend_server_lib.Main.command
;;
