<cfprocessingdirective pageencoding = "utf-8">

<!DOCTYPE html>
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2" style="position:relative; left:-15px">
                <div class="col-sm-6">
                    <h4 style="color:#2675fb">Notas de Versão</h4>
                </div>
            </div>
        </div><!-- /.container-fluid -->
    </section>
        
    <section class="content" style="margin-bottom:50px;position:relative; top:-20px">
        <div class="row" >
            <div class="col-12" id="accordion">
                <div class="card card-primary card-outline">
                    <a class="d-block w-100" data-toggle="collapse" href="#collapseOne">
                        <div class="card-header">
                            <h4 class="card-title w-100">
                                Versão 1.1.0 - 02/11/2023
                            </h4>
                        </div>
                    </a>
                    <div id="collapseOne" class="collapse show" data-parent="#accordion">
                        <div class="card-body">
                            <h5>Novidades:</h5>
                            <ul>
                                <li>Na seção “Acompanhamento”, será possível salvar uma manifestação para envio posterior;</li>
                                <li>Adicionada a funcionalidade "Distribuição", que permite ao órgão avaliado a distribuição das orientações e propostas de melhoria, na seção “Acompanhamento”;</li>
                                <li>Implementado o "Controle das Distribuições". O órgão avaliado poderá acompanhar as orientações e propostas de melhoria distribuídas. Também, os órgãos avaliados poderão visualizar e editar as manifestações salvas, e ainda não enviadas, pelos seus órgãos subordinados;</li>
                                <li>Envio de e-mails de alerta, aos órgãos responsáveis pelas orientações e propostas de melhoria e aos órgãos avaliados, após a disponibilização de um novo processo;</li>
                                <li>Envio de e-mail de alerta, ao órgão responsável, quando ocorrer a distribuição de uma orientação e ou proposta de melhoria.</li>
                            </ul>

                            <h5>Melhorias:</h5>
                            <ul>
                                <li>Adicionados dois novos status: "JUDICIALIZADO" e "PONTO SUSPENSO";</li>
                                <li>Maior velocidade de carregamento do aplicativo e páginas;</li>
                                <li>Maior velocidade de carregamento de tabelas;</li>
                                <li>O controle de usuários está com uma nova interface e melhoria na velocidade de carregamento dos usuários cadastrados.</li>
                            </ul>

                            <h5>Correções:</h5>
                            <ul>
                                <li>Corrigido título dos arquivos em Excel que eram exportados das tabelas;</li>
                                <li>Corrigido largura da tabela que ultrapassava o conteiner quando exibia status com a descrição mais longa;</li>
                                <li>Corrigido o problema que causava a exibição incorreta de imagens;</li>
                                <li>Corrigido o posicionamento do scroll das páginas após a seleção de alguma aba com informações sobre o processo.</li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <!-- Colocar abaixo a nota acima, quando existir nova versão -->
                <!--<div class="card card-primary card-outline">
                    <a class="d-block w-100" data-toggle="collapse" href="#collapseTwo">
                        <div class="card-header">
                            <h4 class="card-title w-100">
                                2. Aenean massa
                            </h4>
                        </div>
                    </a>
                    <div id="collapseTwo" class="collapse" data-parent="#accordion">
                        <div class="card-body">
                            Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
                        </div>
                    </div>
                </div>-->

                
            </div>
        </div>
        
    </section>




</html>
