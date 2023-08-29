<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Geração de relatórios</title>
<link href="../../geral/css/form_style.css" rel="stylesheet" type="text/css" />
</head>

<body>

	<script language="javascript">
		
			function gerarRelatorio(rel) {
				var tamanho = rel.length;
				var valor ='';
				for(var i = 0; i < tamanho; i++) {
					if(rel[i].checked) {
						valor = rel[i].value;
						if(valor == 'relatorioPDF'){
							frmRelatorio.action = 'exportarPagina_PDF.cfm';
							frmRelatorio.submit();
						}
						if(valor == 'relatorioHTML'){
							frmRelatorio.action = 'relatorioHTML.cfm';
							frmRelatorio.submit();
						}
					}
				}
			}

		</script>
		<!-- Início header -->
		<div id="header">
			<div id="logo">
				<h1>Relatório de Inspeção - Sarin</a></h1>				
			</div>
		</div>
		<!-- Fim header -->
		<div id="wrapper">
			<!-- Início page -->
			<div id="page">
			<div id="page-bg">
			
				<!-- Inicio Barra Lateral Esquerda-->
				<div id="sidebar1" class="sidebar">
				
				</div>
				<!-- Fim da Barra Lateral Esquerda-->
				
				<!-- Início content -->				
				<!-- Aqui serão exibidos os campos para o usuário e conterá as tags coldfusion-->
				<div id="content">
				
				<form name="frmRelatorio" method="post" class="form">
				
				<label class="labelcell">Informe o Id:</label><input type="text" name="id">
				<br />
				<br /> 
				
				<label class="labelcell">Escolha uma op&ccedil;&atilde;o para o relat&oacute;rio</label><p>
				<br />
				<label class="labelcell">Exportar para PDF: </label>
				<input type="radio" class="labelcell" name="rel" value="relatorioPDF"/>
				<br />
				<label class="labelcell">Exibir em HTML: </label>
				<input type="radio" class="labelcell" name="rel" value="relatorioHTML"/><p>
				
				<br />
				<input type="button" name="confirmar" value="Confirmar" 
				onclick="gerarRelatorio(document.forms[0])"/>
				</form>

				</div>	
				<!-- Fim content -->
		
				<div style="clear: both;">&nbsp;</div>
		</div>
		</div>
	<!-- Fim page -->
	</div>
	
</body>
</html>
