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
                    <a class="d-block w-100" data-toggle="collapse" href="#collapse121">
                        <div class="card-header">
                            <h4 class="card-title w-100">
                                Versão 1.2.1 - 18/07/2024
                            </h4>
                        </div>
                    </a>
                    <div id="collapse121" class="collapse show" data-parent="#accordion">
                        <div class="card-body">
                            <h5>Novidades:</h5>
                            <ul>
                                <li>Criado o perfil "DIRETORIA";</li>
                            </ul>

                            <h5>Correções:</h5>
                            <ul>
                                <li>Corrigida a seleção de orientações para toda a linha das tabelas de acompanhamento e consulta por orientação.</li>
                            </ul>

                            <h5 style="color:#dc3545">Observação:</h5>
                            <ul style="color:#dc3545">
                                <li>No momento, os resultados do indicador DGCI - Processos, demonstrados neste módulo, não são considerados no resultado do DGCI - Unidades, que consta no Plano de Trabalho das SE.</li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="card card-primary card-outline">
                    <a class="d-block w-100" data-toggle="collapse" href="#collapse3">
                        <div class="card-header">
                            <h4 class="card-title w-100">
                                Versão 1.2.0 - 23/05/2024
                            </h4>
                        </div>
                    </a>
                    <div id="collapse3" class="collapse" data-parent="#accordion">
                        <div class="card-body">
                            <h5>Novidades:</h5>
                            <ul>
                                <li>Criadas as Consultas dos Indicadores (Acompanhamento e Mensal), para os Órgãos Avaliados;</li>
                                <li>Criada a Consulta Indicador Mensal para o Controle Interno;</li>
                                <li>Perfis CI - REGIONAL (Gestor Nível 1) - Execução e  CI - REGIONAL - SCIA - Acompanhamento, agora terão acesso aos processos com origem na GCIA e GACE, além da GCOP.</li>
                            </ul>

                            <h5>Melhorias:</h5>
                            <ul>
                                <li>Modificada a aparência dos botões de opção para as consultas;</li> 
                                <li>Adicionado botão para retornar ao topo das páginas;</li>  
                            </ul>
                            <h5>Correções:</h5>
                            <ul>
                                <li>Corrigida a visualização no menu do link da página atualmente aberta;</li>
                                <li>Corrigida a visualização de tabelas em telas menores.</li>
                            </ul>

                            <h5 style="color:#dc3545">Observação:</h5>
                            <ul style="color:#dc3545">
                                <li>No momento, os resultados do indicador DGCI - Processos, demonstrados neste módulo, não são considerados no resultado do DGCI - Unidades, que consta no Plano de Trabalho das SE.</li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="card card-primary card-outline">
                    <a class="d-block w-100" data-toggle="collapse" href="#collapse2">
                        <div class="card-header">
                            <h4 class="card-title w-100">
                                Versão 1.1.1 - 02/01/2024
                            </h4>
                        </div>
                    </a>
                    <div id="collapse2" class="collapse" data-parent="#accordion">
                        <div class="card-body">
                            <h5>Novidades:</h5>
                            <ul>
                                <li>Criada a Consulta Propostas de Melhoria;</li>
                                <li>Criado novo perfil de acesso: CI - REGIONAL - SCIA - Acompanhamento.</li>
                            </ul>

                            <h5>Melhorias:</h5>
                            <ul>
                                <li>Adicionado menu Consultas, agrupando todas as consultas do SNCI-Processos;</li>  
                            </ul>

                            
                        </div>
                    </div>
                </div>
                <div class="card card-primary card-outline">
                    <a class="d-block w-100" data-toggle="collapse" href="#collapse1">
                        <div class="card-header">
                            <h4 class="card-title w-100">
                                Versão 1.1.0 - 02/11/2023
                            </h4>
                        </div>
                    </a>
                    <div id="collapse1" class="collapse " data-parent="#accordion">
                        <div class="card-body">
                            <h5>Novidades:</h5>
                            <ul>
                                <li>Na seção “Acompanhamento”, será possível salvar uma manifestação para envio posterior;</li>
                                <li>Adicionada a funcionalidade "Distribuição", que permite ao órgão avaliado a distribuição das orientações e propostas de melhoria, na seção “Acompanhamento”;</li>
                                <li>Implementado o "Controle das Distribuições". O órgão avaliado poderá acompanhar as orientações e propostas de melhoria distribuídas. Também, os órgãos avaliados poderão visualizar e editar as manifestações salvas, e ainda não enviadas, pelos seus órgãos subordinados;</li>
                                <li>Envio de e-mails de alerta, aos órgãos responsáveis pelas orientações e propostas de melhoria e aos órgãos avaliados, após a disponibilização de um novo processo;</li>
                                <li>Envio de e-mail de alerta, ao órgão responsável, quando ocorrer a distribuição de uma orientação e ou proposta de melhoria;</li>
                                <li>Implementada a funcionalidade Consulta de Órgãos, apenas para o perfil CI - MASTER ACOMPANHAMENTO (GESTOR NÍVEL 4).</li>
                            </ul>

                            <h5>Melhorias:</h5>
                            <ul>
                                <li>Adicionados dois novos status: "JUDICIALIZADO" e "PONTO SUSPENSO";</li>
                                <li>Maior velocidade de carregamento das páginas;</li>
                                <li>Maior velocidade de carregamento de tabelas;</li>
                                <li>O controle de usuários está com uma nova interface e melhoria na velocidade de carregamento dos usuários cadastrados.</li>
                            </ul>

                            <h5>Correções:</h5>
                            <ul>
                                <li>Corrigido título dos arquivos em Excel que eram exportados das tabelas;</li>
                                <li>Corrigida a largura da tabela que ultrapassava o container quando exibia status com descrição mais longa;</li>
                                <li>Corrigido o problema que causava a exibição incorreta de imagens;</li>
                                <li>Corrigido o posicionamento do scroll das páginas após a seleção de alguma aba com informações sobre o processo.</li>
                            </ul>
                        </div>
                    </div>
                </div>
                                
            </div>
        </div>
        
    </section>




</html>
