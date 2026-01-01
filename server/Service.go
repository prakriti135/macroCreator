package server

var serverMap = make(map[string]*service)

type service struct {
	clientMap map[string]string
}

func getServer(id string) *service {
	serv, ok := serverMap[id]
	if !ok {
		return nil
	}
	return serv
}

func createServer(id string) *service {
	var s service
	s.clientMap = make(map[string]string)
	serverMap[id] = &s
	return &s
}
