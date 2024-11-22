<cfprocessingdirective pageEncoding ="utf-8">  
<!DOCTYPE html>
<html>

<head>
	<meta charset="UTF-8">
	<title>novos campos</title>
  <link rel="stylesheet" href="public/bootstrap/bootstrap.min.css"> 
	<link href="public/jquery-ui/jquery-ui.min.css" rel="stylesheet">
	<link href="public/site.css" rel="stylesheet">
	<script src="public/jquery-3.7.1.min.js"></script>
	<script src="public/jquery-ui/jquery-ui.min.js"></script>
  <script src="public/getTime.js"></script>
  <script src="public/bootstrap/bootstrap.bundle.min.js"></script>
  <script type="text/javascript" src="public/axios.min.js"></script>
	
</head>
<body>
	<div class="wrapper"> 
		<header>
			SISTEMA NACIONAL DE CONTROLE INTERNO - SNCI (UNIDADES)
		</header>  
		<div class="content">
			<div class="main">
				<h1 align="center">Tabelas do PACIN</h1>
				<div id="accordion">
            <h2> Classificação do Controle</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Classificações Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="clasctrl" name="clasctrl" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="clasctrl_desc" class="label">Descrição da Classificação</label>
              </div>
              <div>
                <textarea  name="clasctrl_desc" id="clasctrl_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgclasctrl" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_clasctrl" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','clasctrl','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_clasctrl" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','clasctrl','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_clasctrl" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','clasctrl','Confirmar Exclusão?')">
              </div>  
            </div>
            <h2> Categoria do Controle</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Categorias Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="categctrl" name="categctrl" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="categctrl_desc" class="label">Descrição da Categoria</label>
              </div>
              <div>
                <textarea  name="categctrl_desc" id="categctrl_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgcategctrl" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_categctrl" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','categctrl','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_categctrl" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','categctrl','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_categctrl" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','categctrl','Confirmar Exclusão?')">
              </div>  
            </div>
            <h2> Risco Identificado por Categoria</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Riscos por Categoria Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="categrisco" name="categrisco" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="categrisco_desc" class="label">Descrição do Risco por Categoria</label>
              </div>
              <div>
                <textarea  name="categrisco_desc" id="categrisco_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgcategrisco" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_categrisco" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','categrisco','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_categrisco" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','categrisco','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_categrisco" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','categrisco','Confirmar Exclusão?')">
              </div>  
            </div>
            <h2> Macroprocesso</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Macroprocessos Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="macproc" name="macproc" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="macproc_desc" class="label">Descrição do Macroprocesso</label>
              </div>
              <div>
                <textarea  name="macproc_desc" id="macproc_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgmacproc" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_macproc" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','macproc','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_macproc" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','macproc','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_macproc" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','macproc','Confirmar Exclusão?')">
              </div>  
            </div> 
            <h2> Processo-N1</h2>
            <div>
              <div class="row">
                <div class="col">
                  <label class="label">Macroprocessos</label>
              </div>
                <div class="col">
                    <label class="label">Processos-N1 Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                  <label>         
                      <select id="macprocn1" name="macprocn1" class="form-select" aria-label="Default select example">
                      </select>
                  </label>
                </div>
                <div class="col">
                    <label>            
                        <select id="procn1" name="procn1" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="procn1_desc" class="label">Descrição do Processo-N1</label>
              </div>
              <div>
                <textarea  name="procn1_desc" id="procn1_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgprocn1" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_procn1" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','procn1','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_procn1" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','procn1','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_procn1" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','procn1','Confirmar Exclusão?')">
              </div>  
            </div> 
            <h2> Processo-N2</h2>
            <div>
              <div class="row">
                <div class="col">
                  <label class="label">Macroprocessos</label>
                </div>
                <div class="col">
                    <label class="label">Processos-N1</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                  <label>         
                      <select id="macprocn2" name="macprocn2" class="form-select" aria-label="Default select example">
                      </select>
                  </label>
                </div>
                <div class="col">
                    <label>            
                        <select id="procn1n2" name="procn1n2" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div> 
              <p></p> 
              <div class="row">
                <div class="col">
                  <label class="label">Processos-N2 Existentes</label>
              </div>
              </div>
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="procn2" name="procn2" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="procn2_desc" class="label">Descrição do Processo-N2</label>
              </div>
              <div>
                <textarea  name="procn2_desc" id="procn2_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgprocn2" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_procn2" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','procn2','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_procn2" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','procn2','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_procn2" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','procn2','Confirmar Exclusão?')">
              </div>  
            </div>   
            <h2> Processo-N3</h2>
            <div>
              <div class="row">
                <div class="col">
                  <label class="label">Macroprocessos</label>
                </div>
                <div class="col">
                    <label class="label">Processos-N1</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                  <label>         
                      <select id="macprocn3" name="macprocn3" class="form-select" aria-label="Default select example">
                      </select>
                  </label>
                </div>
                <div class="col">
                    <label>            
                        <select id="procn1n2n3" name="procn1n2n3" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div> 
              <p></p> 
              <div class="row">
                <div class="col">
                  <label class="label">Processos-N2</label>
                </div>
              </div>
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="procn2n3" name="procn2n3" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>               
              <div class="row">
                <div class="col">
                  <label class="label">Processos-N3 Existentes</label>
                </div>
              </div>
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="procn3" name="procn3" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="procn3_desc" class="label">Descrição do Processo-N3</label>
              </div>
              <div>
                <textarea  name="procn3_desc" id="procn3_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgprocn3" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_procn3" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','procn3','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_procn3" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','procn3','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_procn3" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','procn3','Confirmar Exclusão?')">
              </div>  
            </div>  
            <h2> Gestor do Processo (Diretoria)</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Diretorias Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="gestordir" name="gestordir" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="gestordir_desc" class="label">Descrição da Diretoria do Processo</label>
              </div>
              <div>
                <textarea  name="gestordir_desc" id="gestordir_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msggestordir" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_gestordir" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','gestordir','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_gestordir" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','gestordir','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_gestordir" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','gestordir','Confirmar Exclusão?')">
              </div>  
            </div>  
            <h2> Gestor do Processo (Departamento)</h2>
            <div>
              <div class="row">
                <div class="col">
                  <label class="label">Diretoria</label>
              </div>
                <div class="col">
                    <label class="label">Departamentos Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                  <label>         
                      <select id="gestordirdepto" name="gestordirdepto" class="form-select" aria-label="Default select example">
                      </select>
                  </label>
                </div>
                <div class="col">
                    <label>            
                        <select id="gestordepto" name="gestordepto" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="gestordepto_desc" class="label">Descrição do Departamento</label>
              </div>
              <div>
                <textarea  name="gestordepto_desc" id="gestordepto_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msggestordepto" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_gestordepto" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','gestordepto','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_gestordepto" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','gestordepto','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_gestordepto" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','gestordepto','Confirmar Exclusão?')">
              </div>  
            </div>  
            <h2> Objetivo Estratégico</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Objetivos Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="objtestra" name="objtestra" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="objtestra_desc" class="label">Descrição do Objetivo</label>
              </div>
              <div>
                <textarea  name="objtestra_desc" id="objtestra_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgobjtestra" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_objtestra" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','objtestra','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_objtestra" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','objtestra','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_objtestra" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','objtestra','Confirmar Exclusão?')">
              </div>  
            </div>    
            <h2> Risco Estratégico</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Riscos Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="riscestra" name="riscestra" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="riscestra_desc" class="label">Descrição do Risco</label>
              </div>
              <div>
                <textarea  name="riscestra_desc" id="riscestra_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgriscestra" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_riscestra" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','riscestra','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_riscestra" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','riscestra','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_riscestra" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','riscestra','Confirmar Exclusão?')">
              </div>  
            </div> 
            <h2> Indicador Estratégico</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Indicadores Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="indiestra" name="indiestra" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="indiestra_desc" class="label">Descrição do Indicador</label>
              </div>
              <div>
                <textarea  name="indiestra_desc" id="indiestra_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgindiestra" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_indiestra" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','indiestra','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_indiestra" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','indiestra','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_indiestra" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','indiestra','Confirmar Exclusão?')">
              </div>  
            </div>   
            <h2> Componente COSO-2013</h2>
            <div>
              <div class="row">
                <div class="col">
                    <label class="label">Componentes Existentes</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="compcoso2013" name="compcoso2013" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="compcoso2013_desc" class="label">Descrição do Componente</label>
              </div>
              <div>
                <textarea  name="compcoso2013_desc" id="compcoso2013_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgcompcoso2013" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_compcoso2013" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','compcoso2013','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_compcoso2013" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','compcoso2013','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_compcoso2013" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','compcoso2013','Confirmar Exclusão?')">
              </div>  
            </div>  
            <h2> Princípios COSO-2013</h2>
            <div>
              <div class="row">
                <div class="col">
                  <label class="label">Componente COSO-2013</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                  <label>         
                      <select id="compcoso2013princ" name="compcoso2013princ" class="form-select" aria-label="Default select example">
                      </select>
                  </label>
                </div>
              </div>  
              <p></p>
              <div class="row">
                <div class="col">
                    <label class="label">Princípio COSO-2013</label>
                </div>
              </div> 
              <div class="row">
                <div class="col">
                    <label>            
                        <select id="princoso2013" name="princoso2013" class="form-select" aria-label="Default select example">
                        </select>
                    </label>
                </div>
              </div>  
              <p></p>          
              <div>
                <label for="princoso2013_desc" class="label">Descrição do Princípio COSO-2013</label>
              </div>
              <div>
                <textarea  name="princoso2013_desc" id="princoso2013_desc" cols="80" rows="1" wrap="VIRTUAL" title="0"></textarea>		
              </div>
              <p></p>
              <div id="msgprincoso2013" class="msg" style="font-family: sans-serif;font-size: 14px;font-weight: 250;background: #F00;color: #FFF;padding: 10px;border-radius: 10px;">
              </div>
              <p></p>
              <div align="center">
                <input id="inc_princoso2013" class="btn btn-primary" type="button" value="Confirmar Inclusão" onclick="validarDados('inc','princoso2013','Confirmar Inclusão?')">&nbsp;&nbsp;
                <input id="alt_princoso2013" class="btn btn-warning" type="button" value="Confirmar Alteração" onclick="validarDados('alt','princoso2013','Confirmar Alteração?')">&nbsp;&nbsp;
                <input id="exc_princoso2013" class="btn btn-danger" type="button" value="Confirmar Exclusão" onclick="validarDados('exc','princoso2013','Confirmar Exclusão?')">
              </div>  
            </div>                                                                                                                         
				</div>
			</div>
		</div>
		<footer>
			<p>Cadastro das tabelas do PACIN que passam a compor o Grupo/Item <strong><script>printToday();</script></strong><strong id="time"></strong></p>
		</footer>
	</div>
</body>
<script>
  $(document).ready(function () {
    //alert('Aqui')
    $("#msgclasctrl").hide();
    $("#msgcategctrl").hide();
    $("#msgcategrisco").hide();
    $("#msgmacproc").hide();
    $("#msgprocn1").hide();
    $("#msgprocn2").hide();
    $("#msgprocn3").hide();
    $("#msggestordir").hide();
    $("#msggestordepto").hide();
    $("#msgobjtestra").hide();
    $("#msgriscestra").hide();
    $("#msgindiestra").hide();
    $("#msgcompcoso2013").hide();
    $("#msgprincoso2013").hide();
    
    
    
    
    $('#accordion').accordion({
      active: false,
      collapsible: true,
      icons: {
        header: 'ui-icon-circle-plus',
        activeHeader: 'ui-icon-circle-minus'
      },
      animate: false
    });
    
    function displayTime() {
      $('#time').text(getTime(true));
    }
    displayTime();
    setInterval(displayTime,1000);

    //buscar Classificação de Controle
    classifctrl();
    categctrl();
    categrisco();
    macproc();
    gestordir();
    objtestra();
    riscestra();
    indiestra();
    compcoso2013();
    
    
  }); // end ready

  function printToday() {
    var today = new Date();
    document.write(today.toLocaleDateString('pt-br'));
  } 
//*****************************************************
  //Críticas Gerais para Submit
  function validarDados(a,b,c){
      //inicio críticas, front-end e back-end da Classificação do Controle
      //alert('a:  '+a+' b:  '+b+' c:  '+c)
      let continuarSN = 'S'
      if(b == 'clasctrl') {
          if ($('#clasctrl_desc').val() == '' || $('#clasctrl_desc').val() == '---') {
              alert('Informar a Descrição da Classificação do Controle!');
              $('#clasctrl_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#clasctrl  > option').each(function() {
                if($(this).text() == $('#clasctrl_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Classificação do Controle!');
                  continuarSN = 'N'
                  return false;
                }
              })
          }   
          if(continuarSN == 'S'){     
            if(window.confirm(c)){           
                // submeter ao banco de dados
                //buscar classificação do controle
                let tpctid = $('#clasctrl_desc').attr("title")
                let acao = a
                let tpctdesc = $('#clasctrl_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_classifctrl",
                    acao: acao,
                    tpctid: tpctid,
                    tpctdesc: tpctdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgclasctrl").html(dados);
                  $("#msgclasctrl").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  classifctrl();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
                return false;
            }
          }
      }// final críticas, front-end e back-end da Classificação do Controle
      if(b == 'categctrl') {
          if ($('#categctrl_desc').val() == '' || $('#categctrl_desc').val() == '---') {
              alert('Informar a Descrição da Categoria do Controle!');
              $('#categctrl_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#categctrl  > option').each(function() {
                if($(this).text() == $('#categctrl_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Categoria do Controle!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar classificação do controle
                let ctctid = $('#categctrl_desc').attr("title")
                let acao = a
                let ctctdesc = $('#categctrl_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_categctrl",
                    acao: acao,
                    ctctid: ctctid,
                    ctctdesc: ctctdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgcategctrl").html(dados);
                  $("#msgcategctrl").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  categctrl();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end da Categoria do Controle
      if(b == 'categrisco') {
          if ($('#categrisco_desc').val() == '' || $('#categrisco_desc').val() == '---') {
              alert('Informar a Descrição do Risco Identificado por Categoria!');
              $('#categrisco_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#categrisco  > option').each(function() {
                if($(this).text() == $('#categrisco_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Risco por Categoria!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar classificação do controle
                let ctrcid = $('#categrisco_desc').attr("title")
                let acao = a
                let ctrcdesc = $('#categrisco_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_categrisco",
                    acao: acao,
                    ctrcid: ctrcid,
                    ctrcdesc: ctrcdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgcategrisco").html(dados);
                  $("#msgcategrisco").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  categrisco();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end do Risco Identificado por Categoria
      if(b == 'macproc') {
          if ($('#macproc_desc').val() == '' || $('#macproc_desc').val() == '---') {
              alert('Informar a Descrição do Macroprocesso!');
              $('#macproc_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#macproc  > option').each(function() {
                if($(this).text() == $('#macproc_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Macroprocesso!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar classificação do controle
                let mapcid = $('#macproc_desc').attr("title")
                let acao = a
                let mapcdesc = $('#macproc_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_macproc",
                    acao: acao,
                    mapcid: mapcid,
                    mapcdesc: mapcdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgmacproc").html(dados);
                  $("#msgmacproc").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  macproc();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end do Macroprocesso    
      if(b == 'procn1') {
          if ($('#procn1_desc').val() == '' || $('#procn1_desc').val() == '---') {
              alert('Informar a Descrição do Processo-N1!');
              $('#procn1_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#procn1  > option').each(function() {
                if($(this).text() == $('#procn1_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Processo-N1!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar classificação do controle
                let acao = a
                let pcn1mapcid = $('#macprocn1').val()
                let pcn1id = $('#procn1_desc').attr("title")
                let pcn1desc = $('#procn1_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_procn1",
                    acao: acao,
                    pcn1mapcid: pcn1mapcid,
                    pcn1id: pcn1id,
                    pcn1desc: pcn1desc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgprocn1").html(dados);
                  $("#msgprocn1").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  procn1();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end do Processo-N1       
      if(b == 'procn2') {
          if ($('#procn2_desc').val() == '' || $('#procn2_desc').val() == '---') {
              alert('Informar a Descrição do Processo-N2!');
              $('#procn2_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#procn2  > option').each(function() {
                if($(this).text() == $('#procn2_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Processo-N2!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar Processo-N2
                let acao = a
                let pcn1mapcid = $('#macprocn2').val()
                let pcn1id = $('#procn1n2').val()
                let pcn2id = $('#procn2_desc').attr("title")
                let pcn2desc = $('#procn2_desc').val()
                //alert('pcn1mapcid: '+pcn1mapcid+' pcn1id: '+pcn1id+' pcn2id: '+pcn2id+' pcn2desc: '+pcn2desc)
                //return false
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_procn2",
                    acao: acao,
                    pcn1mapcid: pcn1mapcid,
                    pcn1id: pcn1id,
                    pcn2id: pcn2id,
                    pcn2desc: pcn2desc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgprocn2").html(dados);
                  $("#msgprocn2").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  procn2();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end do Processo-N2    
      if(b == 'procn3') {
          if ($('#procn3_desc').val() == '' || $('#procn3_desc').val() == '---') {
              alert('Informar a Descrição do Processo-N3!');
              $('#procn3_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#procn3  > option').each(function() {
                if($(this).text() == $('#procn3_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Processo-N3!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar classificação do controle              
                let acao = a
                let pcn1mapcid = $('#macprocn3').val()
                let pcn1id = $('#procn1n2n3').val()
                let pcn2id = $('#procn2n3').val()
                let pcn3id = $('#procn3_desc').attr("title")
                let pcn3desc = $('#procn3_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_procn3",
                    acao: acao,
                    pcn1mapcid: pcn1mapcid,
                    pcn1id: pcn1id,
                    pcn2id: pcn2id,
                    pcn3id: pcn3id,
                    pcn3desc: pcn3desc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgprocn3").html(dados);
                  $("#msgprocn3").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  procn3();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end do Processo-N3   
      if(b == 'gestordir') {
          if ($('#gestordir_desc').val() == '' || $('#gestordir_desc').val() == '---') {
              alert('Informar a Descrição da Diretoria do Processo!');
              $('#gestordir_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#gestordir  > option').each(function() {
                if($(this).text() == $('#gestordir_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Diretoria do Processo!');
                  continuarSN = 'N'
                  return false;
                }
              })
          }   
          if(continuarSN == 'S'){     
            if(window.confirm(c)){           
                // submeter ao banco de dados
                //buscar Diretoria do Processo
                let acao = a
                let digpid = $('#gestordir_desc').attr("title")
                let digpdesc = $('#gestordir_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_gestordir",
                    acao: acao,
                    digpid: digpid,
                    digpdesc: digpdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msggestordir").html(dados);
                  $("#msggestordir").show(500);
                })
                // refazer e atualizar o select: gestordir
                setTimeout(function() {
                  gestordir();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
                return false;
            }
          }
      }// final críticas, front-end e back-end da Gestor do Processo  diretoria      
      if(b == 'gestordepto') {
          if ($('#gestordepto_desc').val() == '' || $('#gestordepto_desc').val() == '---') {
              alert('Informar a Sigla do Departamento!');
              $('#gestordepto_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#gestordepto  > option').each(function() {
                if($(this).text() == $('#gestordepto_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Departamento!');
                  continuarSN = 'N'
                  return false;
                }
              })
          }   
          if(continuarSN == 'S'){     
            if(window.confirm(c)){           
                // submeter ao banco de dados
                //buscar departamento
                let acao = a
                let dpgpdigpid = $('#gestordirdepto').val()
                let dpgpid = $('#gestordepto_desc').attr("title")                
                let dpgpsigla = $('#gestordepto_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_gestordepto",
                    acao: acao,
                    dpgpdigpid: dpgpdigpid,
                    dpgpid: dpgpid,
                    dpgpsigla: dpgpsigla
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msggestordepto").html(dados);
                  $("#msggestordepto").show(500);
                })
                // refazer e atualizar o select: gestordepto
                setTimeout(function() {
                  gestordepto();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
                return false;
            }
          }
      }// final críticas, front-end e back-end da Gestor do Processo  departamento    
      if(b == 'objtestra') {
          if ($('#objtestra_desc').val() == '' || $('#objtestra_desc').val() == '---') {
              alert('Informar a Descrição do Objetivo Estratégico!');
              $('#objtestra_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#objtestra  > option').each(function() {
                if($(this).text() == $('#objtestra_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Objetivo Estratégico!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar objetivo estratégico
                let obesid = $('#objtestra_desc').attr("title")
                let acao = a
                let obesdesc = $('#objtestra_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_objtestra",
                    acao: acao,
                    obesid: obesid,
                    obesdesc: obesdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgobjtestra").html(dados);
                  $("#msgobjtestra").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  objtestra();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end da Objetivo estratégico   
      if(b == 'riscestra') {
          if ($('#riscestra_desc').val() == '' || $('#riscestra_desc').val() == '---') {
              alert('Informar a Descrição do Risco Estratégico!');
              $('#riscestra_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#riscestra  > option').each(function() {
                if($(this).text() == $('#riscestra_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Risco Estratégico!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar Risco estratégico              
                let rcesid = $('#riscestra_desc').attr("title")
                let acao = a
                let rcesdesc = $('#riscestra_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_riscestra",
                    acao: acao,
                    rcesid: rcesid,
                    rcesdesc: rcesdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgriscestra").html(dados);
                  $("#msgriscestra").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  riscestra();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end da Risco estratégico    
      if(b == 'indiestra') {
          if ($('#indiestra_desc').val() == '' || $('#indiestra_desc').val() == '---') {
              alert('Informar a Descrição do Indicador Estratégico!');
              $('#indiestra_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#indiestra  > option').each(function() {
                if($(this).text() == $('#indiestra_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Indicador Estratégico!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar Risco estratégico              
                let idesid = $('#indiestra_desc').attr("title")
                let acao = a
                let idesdesc = $('#indiestra_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_indiestra",
                    acao: acao,
                    idesid: idesid,
                    idesdesc: idesdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgindiestra").html(dados);
                  $("#msgindiestra").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  indiestra();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end da Indicador estratégico            
      if(b == 'compcoso2013') {
          if ($('#compcoso2013_desc').val() == '' || $('#compcoso2013_desc').val() == '---') {
              alert('Informar a Descrição do Componente COSO-2013!');
              $('#compcoso2013_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#compcoso2013  > option').each(function() {
                if($(this).text() == $('#compcoso2013_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Componente COSO-2013!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar Componente COSO-2013          
                let cpcsid = $('#compcoso2013_desc').attr("title")
                let acao = a
                let cpcsdesc = $('#compcoso2013_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_compcoso2013",
                    acao: acao,
                    cpcsid: cpcsid,
                    cpcsdesc: cpcsdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgcompcoso2013").html(dados);
                  $("#msgcompcoso2013").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  compcoso2013();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end da Componente COSO 2013     
      if(b == 'princoso2013') {
          if ($('#princoso2013_desc').val() == '' || $('#princoso2013_desc').val() == '---') {
              alert('Informar a Descrição do Componente COSO-2013!');
              $('#princoso2013_desc').focus()
              continuarSN = 'N'
              return false;
          }
          if (a != 'exc') {
              $('#princoso2013  > option').each(function() {
                if($(this).text() == $('#princoso2013_desc').val()) {
                  alert('Texto Informado já existe no Cadastro: Componente COSO-2013!');
                  continuarSN = 'N'
                  return false;
                }
              })
          } 
          if(continuarSN == 'S'){       
            if(window.confirm(c)){  
                // submeter ao banco de dados
                //buscar Princípio COSO-2013     
                let prcscpcsid = $('#compcoso2013princ').val()    
                let prcsid = $('#princoso2013_desc').attr("title")
                let acao = a
                let prcsdesc = $('#princoso2013_desc').val()
                axios.get("CFC/grupoitem.cfc",{
                  params: {
                    method: "cad_princoso2013",
                    acao: acao,
                    prcscpcsid: prcscpcsid,
                    prcsid: prcsid,
                    prcsdesc: prcsdesc
                  }
                })
                .then(data =>{
                  var vlr_ini = data.data.indexOf("<string>");
                  var vlr_fin = data.data.length
                  let dados = data.data.substring(vlr_ini,vlr_fin);
                  $("#msgprincoso2013").html(dados);
                  $("#msgprincoso2013").show(500);
                })
                // refazer e atualizar o select: clasctrl
                setTimeout(function() {
                  princoso2013();
                }, 500);
              // fim - submeter ao banco de dados
            }else{
              return false;
            }
          }
      }// final críticas, front-end e back-end da Princípio COSO 2013            
  }
  // início ACCORDION 
  //(Classificação do Controle)
  $('#clasctrl').click(function() {
    $("#msgclasctrl").hide();
    $('#clasctrl_desc').val($('#clasctrl option:selected').html());
    let auxval = $('#clasctrl').val()
    $('#clasctrl_desc').attr("title",auxval);
    //alert($('#clasctrl option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgclasctrl").hide();
  })
  $('#clasctrl_desc').focus(function() {
    $("#msgclasctrl").hide();
  })//(Classificação do Controle)

  //(Categoria do Controle)
  $('#categctrl').click(function() {
    $("#msgcategctrl").hide();
    $('#categctrl_desc').val($('#categctrl option:selected').html());
    let auxval = $('#categctrl').val()
    $('#categctrl_desc').attr("title",auxval);
    //alert($('#categctrl option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgcategctrl").hide();
  })
  $('#categctrl_desc').focus(function() {
    $("#msgcategctrl").hide();
  })//(Categoria do Controle)

  //(Risco Identificado por Categoria)
  $('#categrisco').click(function() {
    $("#msgcategrisco").hide();
    $('#categrisco_desc').val($('#categrisco option:selected').html());
    let auxval = $('#categrisco').val()
    $('#categrisco_desc').attr("title",auxval);
    //alert($('#categrisco option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgcategrisco").hide();
  })
  $('#categrisco_desc').focus(function() {
    $("#msgcategrisco").hide();
  })//(Risco Identificado por Categoria)  

  //(Macroprocesso)
  $('#macproc').click(function() {
    $("#msgmacproc").hide();
    $('#macproc_desc').val($('#macproc option:selected').html());
    let auxval = $('#macproc').val()
    $('#macproc_desc').attr("title",auxval);
    //alert($('#macproc option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgmacproc").hide();
  })
  $('#macproc_desc').focus(function() {
    $("#msgmacproc").hide();
  })//(Macroprocesso) 

  //(Processo-N1)
  $('#procn1').click(function() {
    $("#msgprocn1").hide();
    $('#procn1_desc').val($('#procn1 option:selected').html());
    let auxval = $('#procn1').val()
    $('#procn1_desc').attr("title",auxval);
    //alert($('#procn1 option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgprocn1").hide();
  })
  $('#procn1_desc').focus(function() {
    $("#msgprocn1").hide();
  })//(Processo-N1) 

  //(Processo-N2)
  $('#procn2').click(function() {
    $("#msgprocn2").hide();
    $('#procn2_desc').val($('#procn2 option:selected').html());
    let auxval = $('#procn2').val()
    $('#procn2_desc').attr("title",auxval);
    //alert($('#procn2 option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgprocn2").hide();
  })
  $('#procn2_desc').focus(function() {
    $("#msgprocn2").hide();
  })//(Processo-N2)   

  //(Processo-N3)
  $('#procn3').click(function() {
    $("#msgprocn3").hide();
    $('#procn3_desc').val($('#procn3 option:selected').html());
    let auxval = $('#procn3').val()
    $('#procn3_desc').attr("title",auxval);
    //alert($('#procn3 option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgprocn3").hide();
  })
  $('#procn3_desc').focus(function() {
    $("#msgprocn3").hide();
  })//(Processo-N3)   

  // inicio BUSCAS NA BASE PARA COMPOR AS TELAS
  //buscar classificação do controle
  function classifctrl() {
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "classifctrl"
      }
    })
    .then(data =>{
          let prots = '<option value="" selected>---</option>';
          //console.log(data.data)
          //console.log(data.data.indexOf("COLUMNS"));
          var vlr_ini = data.data.indexOf("COLUMNS");
          var vlr_fin = data.data.length
          vlr_ini = (vlr_ini - 2);
        // console.log('valor inicial: ' + vlr_fin);
          const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
          //console.log(json);
          const dados = json.DATA;
          dados.map((ret) => {
          prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
        });
      $("#clasctrl").html(prots);
    }) 
  } //buscar classificação do controle
  //busca da categoria 
  //busca da categoria 
  function categctrl() {
      
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "categcontrole"
      }
    })
    .then(data =>{
        let prots = '<option value="" selected>---</option>';
        var vlr_ini = data.data.indexOf("COLUMNS");
        var vlr_fin = data.data.length
        vlr_ini = (vlr_ini - 2);
        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
        const dados = json.DATA;
        dados.map((ret) => {
        prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
      });
      $("#categctrl").html(prots);
    })     
  }//busca da categoria   
  //busca da categoria 
  function categrisco() {  
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "categoriarisco"
      }
    })
    .then(data =>{
        let prots = '<option value="" selected>---</option>';
        var vlr_ini = data.data.indexOf("COLUMNS");
        var vlr_fin = data.data.length
        vlr_ini = (vlr_ini - 2);
        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
        const dados = json.DATA;
        dados.map((ret) => {
        prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
      });
      $("#categrisco").html(prots);
    })     
  } //busca da categoria  
  //busca da categoria 
  function macproc() {  
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "macroprocesso"
      }
    })
    .then(data =>{
        let prots = '<option value="" selected>---</option>';
        var vlr_ini = data.data.indexOf("COLUMNS");
        var vlr_fin = data.data.length
        vlr_ini = (vlr_ini - 2);
        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
        const dados = json.DATA;
        dados.map((ret) => {
        prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
      });
      $("#macproc").html(prots);
      $("#macprocn1").html(prots);
      $("#macprocn2").html(prots);
      $("#macprocn3").html(prots);
    })     
  } //busca da categoria
  function procn1() {
    let prots = '<option value="" selected>---</option>';
    $("#procn1").html(prots);
    $('#procn1_desc').val('---');
    //alert($(this).val())
    let PCN1MAPCID = $(macprocn1).val(); 
    if(PCN1MAPCID != ''){                         
        axios.get("CFC/grupoitem.cfc",{
            params: {
                method: "macroprocesson1",
                PCN1MAPCID: PCN1MAPCID
            }
        })
        .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
            });
            $("#procn1").html(prots);
        })  
    }
  }//refazer buscas Processo-N1 
  function procn2() {
    let prots = '<option value="" selected>---</option>';
    $('#procn2_desc').val('---');
    //alert($(this).val())
    let PCN1MAPCID = $(macprocn2).val(); 
    let PCN1ID = $(procn1n2).val(); 
    if(PCN1MAPCID != ''){                         
        axios.get("CFC/grupoitem.cfc",{
            params: {
                method: "macroprocesson2",
                PCN1MAPCID: PCN1MAPCID,
                PCN1ID: PCN1ID
            }
        })
        .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
            });
            $("#procn2").html(prots);
        })  
    }
  }//refazer buscas Processo-N2  
  function procn3() {
    let prots = '<option value="" selected>---</option>';
    $('#procn3_desc').val('---');   
    let PCN3PCN2PCN1MAPCID = $(macprocn3).val(); 
    let PCN3PCN2PCN1ID = $(procn1n2n3).val(); 
    let PCN3PCN2ID = $(procn2n3).val(); 
    //let procn3 = $(procn3).val(); 
    if(PCN3PCN2PCN1MAPCID != ''){                         
        axios.get("CFC/grupoitem.cfc",{
            params: {
                method: "macroprocesson3",
                PCN3PCN2PCN1MAPCID: PCN3PCN2PCN1MAPCID,
                PCN3PCN2PCN1ID: PCN3PCN2PCN1ID,
                PCN3PCN2ID: PCN3PCN2ID
            }
        })
        .then(data =>{
            var vlr_ini = data.data.indexOf("COLUMNS");
            var vlr_fin = data.data.length
            vlr_ini = (vlr_ini - 2);
            const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
            const dados = json.DATA;
            dados.map((ret) => {
                prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
            });
            $("#procn3").html(prots);
        })  
    }
  }//refazer buscas Processo-N3    
  function gestordir() {
    // buscar gestor do processo  
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "gestordiretoria"
      }
    })
    .then(data =>{
        let prots = '<option value="" selected>---</option>';
        var vlr_ini = data.data.indexOf("COLUMNS");
        var vlr_fin = data.data.length
        vlr_ini = (vlr_ini - 2);
        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
        const dados = json.DATA;
        dados.map((ret) => {
        prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
      });
      $("#gestordir").html(prots);
      $("#gestordirdepto").html(prots);
    }) 
  } //buscar Diretoria do processo
  function gestordepto() {
    // buscar gestor do processo  
    let digpid = $('#gestordirdepto').val(); 
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "gestorprocesso",
      digpid: digpid
      }
    })
    .then(data =>{
        let prots = '<option value="" selected>---</option>';
        var vlr_ini = data.data.indexOf("COLUMNS");
        var vlr_fin = data.data.length
        vlr_ini = (vlr_ini - 2);
        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
        const dados = json.DATA;
        dados.map((ret) => {
        prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
      });
      $("#gestordepto").html(prots);
    }) 
  } //buscar Departamento do processo
  function objtestra() {
      axios.get("CFC/grupoitem.cfc",{
        params: {
        method: "objetivoestrategico"
        }
      })
      .then(data =>{
          let prots = '<option value="" selected>---</option>';
          var vlr_ini = data.data.indexOf("COLUMNS");
          var vlr_fin = data.data.length
          vlr_ini = (vlr_ini - 2);
          const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
          const dados = json.DATA;
          dados.map((ret) => {
          prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
        });
        $("#objtestra").html(prots);
      })     
  } //busca da objetivo estrategico    
  function riscestra() {
      axios.get("CFC/grupoitem.cfc",{
        params: {
        method: "riscoestrategico"
        }
      })
      .then(data =>{
          let prots = '<option value="" selected>---</option>';
          var vlr_ini = data.data.indexOf("COLUMNS");
          var vlr_fin = data.data.length
          vlr_ini = (vlr_ini - 2);
          const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
          const dados = json.DATA;
          dados.map((ret) => {
          prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
        });
        $("#riscestra").html(prots);
      })     
  }//busca da risco estrategico    
  function indiestra() {
      axios.get("CFC/grupoitem.cfc",{
        params: {
        method: "indicadorestrategico"
        }
      })
      .then(data =>{
          let prots = '<option value="" selected>---</option>';
          var vlr_ini = data.data.indexOf("COLUMNS");
          var vlr_fin = data.data.length
          vlr_ini = (vlr_ini - 2);
          const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
          const dados = json.DATA;
          dados.map((ret) => {
          prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
        });
        $("#indiestra").html(prots);
      })     
  }//busca da risco estrategico  
  function compcoso2013() {
    //componentecoso2013 
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "componentecoso"
    }
    })
    .then(data =>{
      let prots = '<option value="" selected>---</option>';
      var vlr_ini = data.data.indexOf("COLUMNS");
      var vlr_fin = data.data.length
      vlr_ini = (vlr_ini - 2);
      const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
      const dados = json.DATA;
      dados.map((ret) => {
        prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
      });
      $("#compcoso2013").html(prots);
      $("#compcoso2013princ").html(prots);
    })      
  }//busca da risco estrategico 
  function princoso2013() {
    // buscar gestor do processo  
    let PRCSCPCSID = $('#compcoso2013princ').val(); 
    axios.get("CFC/grupoitem.cfc",{
      params: {
      method: "principioscoso",
      PRCSCPCSID: PRCSCPCSID
      }
    })
    .then(data =>{
        let prots = '<option value="" selected>---</option>';
        var vlr_ini = data.data.indexOf("COLUMNS");
        var vlr_fin = data.data.length
        vlr_ini = (vlr_ini - 2);
        const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
        const dados = json.DATA;
        dados.map((ret) => {
        prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
      });
      $("#princoso2013").html(prots);
    }) 
  } //buscar Principio coso2013   
  //fim busca na base para compor as telas
  $('#macprocn1').change(function(e){ 
      let prots = '<option value="" selected>---</option>';
      $("#procn1").html(prots);
      $('#procn1_desc').val('---');
      //alert($(this).val())
      let PCN1MAPCID = $(this).val(); 
      if(PCN1MAPCID != ''){                         
          axios.get("CFC/grupoitem.cfc",{
              params: {
                  method: "macroprocesson1",
                  PCN1MAPCID: PCN1MAPCID
              }
          })
          .then(data =>{
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#procn1").html(prots);
          })  
      }
  })//buscar Processo-N1
  $('#macprocn2').change(function(e){ 
      let prots = '<option value="" selected>---</option>';
      $("#procn1n2").html(prots);
      $("#procn2").html(prots);
      $('#procn2_desc').val('---');
      //alert($(this).val())
      let PCN1MAPCID = $(this).val(); 
      if(PCN1MAPCID != ''){                         
          axios.get("CFC/grupoitem.cfc",{
              params: {
                  method: "macroprocesson1",
                  PCN1MAPCID: PCN1MAPCID
              }
          })
          .then(data =>{
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#procn1n2").html(prots);
          })  
      }
  })//buscar procn1n2n3
  $('#macprocn3').change(function(e){ 
      let prots = '<option value="" selected>---</option>';
      $("#procn1n2n3").html(prots);
      $("#procn2n3").html(prots);
      $("#procn3").html(prots);
      $('#procn3_desc').val('---');
      //alert($(this).val())
      let PCN1MAPCID = $(this).val(); 
      if(PCN1MAPCID != ''){                         
          axios.get("CFC/grupoitem.cfc",{
              params: {
                  method: "macroprocesson1",
                  PCN1MAPCID: PCN1MAPCID
              }
          })
          .then(data =>{
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#procn1n2n3").html(prots);
          })  
      }
  })//buscar procn1n2n3 
  $('#procn1n2').change(function(e){
      let prots = '<option value="" selected>---</option>';
      $("#procn2").html(prots);
      $('#procn2_desc').val('---');
      var PCN1MAPCID = $("#macprocn2").val();
      var PCN1ID = $(this).val();
      axios.get("CFC/grupoitem.cfc",{
        params: {
        method: "macroprocesson2",
        PCN1MAPCID: PCN1MAPCID,
        PCN1ID: PCN1ID
        }
      })
      .then(data =>{
          let prots = '<option value="" selected>---</option>';
          var vlr_ini = data.data.indexOf("COLUMNS");
          var vlr_fin = data.data.length
          vlr_ini = (vlr_ini - 2);
          const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
          const dados = json.DATA;
          dados.map((ret) => {
          prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
        });
          $("#procn2").html(prots);
      })  
  })//buscar Processo-N2   
  $('#procn1n2n3').change(function(e){
      let prots = '<option value="" selected>---</option>';
      $("#procn2n3").html(prots);
      $("#procn3").html(prots);
      $('#procn3_desc').val('---');
      var PCN1MAPCID = $("#macprocn3").val();
      var PCN1ID = $(this).val();
      axios.get("CFC/grupoitem.cfc",{
        params: {
        method: "macroprocesson2",
        PCN1MAPCID: PCN1MAPCID,
        PCN1ID: PCN1ID
        }
      })
      .then(data =>{
          let prots = '<option value="" selected>---</option>';
          var vlr_ini = data.data.indexOf("COLUMNS");
          var vlr_fin = data.data.length
          vlr_ini = (vlr_ini - 2);
          const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
          const dados = json.DATA;
          dados.map((ret) => {
          prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
        });
          $("#procn2n3").html(prots);
      })  
  })//buscar Processo-N2N3  
  $('#procn2n3').change(function(e){
      let prots = '<option value="" selected>---</option>';
      $("#procn3").html(prots);
      $('#procn3_desc').val('---');     
      var PCN3PCN2PCN1MAPCID = $("#macprocn3").val();
      var PCN3PCN2PCN1ID = $("#procn1n2n3").val();
      var PCN3PCN2ID = $(this).val();
      axios.get("CFC/grupoitem.cfc",{
        params: {
        method: "macroprocesson3",
        PCN3PCN2PCN1MAPCID: PCN3PCN2PCN1MAPCID,
        PCN3PCN2PCN1ID: PCN3PCN2PCN1ID,
        PCN3PCN2ID: PCN3PCN2ID
        }
      })
      .then(data =>{
          let prots = '<option value="" selected>---</option>';
          var vlr_ini = data.data.indexOf("COLUMNS");
          var vlr_fin = data.data.length
          vlr_ini = (vlr_ini - 2);
          const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
          const dados = json.DATA;
          dados.map((ret) => {
          prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
        });
          $("#procn3").html(prots);
      }) 

  })//buscar Departamento   
  $('#gestordirdepto').change(function(e){ 
      let prots = '<option value="" selected>---</option>';
      $("#gestordepto").html(prots);
      $('#gestordepto_desc').val('---');
      //alert($(this).val())    
      let digpid = $(this).val(); 
      if(gestordirdepto != ''){                         
          axios.get("CFC/grupoitem.cfc",{
              params: {
                  method: "gestorprocesso",
                  digpid: digpid
              }
          })
          .then(data =>{
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#gestordepto").html(prots);
          })  
      }
  })//buscar Departamento  
  $('#compcoso2013princ').change(function(e){ 
      let prots = '<option value="" selected>---</option>';
      $("#princoso2013").html(prots);
      $('#princoso2013_desc').val('---');
      //alert($(this).val())    
      let PRCSCPCSID = $(this).val(); 
      if(PRCSCPCSID != ''){                         
          axios.get("CFC/grupoitem.cfc",{
              params: {
                  method: "principioscoso",
                  PRCSCPCSID: PRCSCPCSID
              }
          })
          .then(data =>{
              var vlr_ini = data.data.indexOf("COLUMNS");
              var vlr_fin = data.data.length
              vlr_ini = (vlr_ini - 2);
              const json = JSON.parse(data.data.substring(vlr_ini,vlr_fin));
              const dados = json.DATA;
              dados.map((ret) => {
                  prots += '<option value="' + ret[0] + '">' + ret[1] + '</option>';
              });
              $("#princoso2013").html(prots);
          })  
      }
  })//buscar Princípio COSO-2013    
  $('#gestordir').click(function() {
    $("#msggestordir").hide();
    $('#gestordir_desc').val($('#gestordir option:selected').html());
    let auxval = $('#gestordir').val()
    $('#gestordir_desc').attr("title",auxval);
    //alert($('#gestordir option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msggestordir").hide();
  })
  $('#gestordir_desc').focus(function() {
    $("#msggestordir").hide();
  })//(diretoria)  
  $('#gestordepto').click(function() {
    $("#msggestordepto").hide();
    $('#gestordepto_desc').val($('#gestordepto option:selected').html());
    let auxval = $('#gestordepto').val()
    $('#gestordepto_desc').attr("title",auxval);
    //alert($('#gestordepto option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msggestordepto").hide();
  })
  $('#gestordepto_desc').focus(function() {
    $("#msggestordepto").hide();
  })//(departamento)   
  $('#objtestra').click(function() {
    $("#msgobjtestra").hide();
    $('#objtestra_desc').val($('#objtestra option:selected').html());
    let auxval = $('#objtestra').val()
    $('#objtestra_desc').attr("title",auxval);
    //alert($('#objtestra option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgobjtestra").hide();
  })
  $('#objtestra_desc').focus(function() {
    $("#msgobjtestra").hide();
  })//(Objetivo estratégico)  
  $('#riscestra').click(function() {
    $("#msgriscestra").hide();
    $('#riscestra_desc').val($('#riscestra option:selected').html());
    let auxval = $('#riscestra').val()
    $('#riscestra_desc').attr("title",auxval);
    //alert($('#riscestra option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgriscestra").hide();
  })
  $('#riscestra_desc').focus(function() {
    $("#msgriscestra").hide();
  })//(Risco estratégico)  
  $('#indiestra').click(function() {
    $("#msgindiestra").hide();
    $('#indiestra_desc').val($('#indiestra option:selected').html());
    let auxval = $('#indiestra').val()
    $('#indiestra_desc').attr("title",auxval);
    //alert($('#indiestra option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgindiestra").hide();
  })
  $('#indiestra_desc').focus(function() {
    $("#msgindiestra").hide();
  })//(Indicador estratégico)   
  $('#compcoso2013').click(function() {
    $("#msgcompcoso2013").hide();
    $('#compcoso2013_desc').val($('#compcoso2013 option:selected').html());
    let auxval = $('#compcoso2013').val()
    $('#compcoso2013_desc').attr("title",auxval);
    //alert($('#compcoso2013 option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgcompcoso2013").hide();
  })
  $('#compcoso2013_desc').focus(function() {
    $("#msgcompcoso2013").hide();
  })//(Componente COSO 2013) 
  $('#princoso2013').click(function() {
    $("#msgprincoso2013").hide();
    $('#princoso2013_desc').val($('#princoso2013 option:selected').html());
    let auxval = $('#princoso2013').val()
    $('#princoso2013_desc').attr("title",auxval);
    //alert($('#princoso2013 option:selected').html())
  });
  $('.btn').hover(function() {
    $("#msgprincoso2013").hide();
  })
  $('#princoso2013_desc').focus(function() {
    $("#msgprincoso2013").hide();
  })//(Princípio COSO 2013)      
  // final BUSCAS NA BASE PARA COMPOR AS TELAS
  // final ACCORDION (Classificação do Controle)
</script>
</html>