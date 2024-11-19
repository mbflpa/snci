<cfprocessingdirective pageencoding = "utf-8">


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Sistema Nacional de Controle Interno</title>
	<!-- Font Awesome -->
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/all.min.css">
	<link rel="stylesheet" href="../SNCI_PROCESSOS/plugins/fontawesome-free/css/fontawesome.min.css">
</head>

<body>

<cftry>

<cfif isDefined("url.arquivo")>
    <cfif ucase(left(trim(url.arquivo),24)) is "\\SAC0424\SISTEMAS\SNCI\" >
	  <cfset vArquivo = url.arquivo>
	<cfelse>
	  <cfset vArquivo = #application.diretorio_anexos# & url.arquivo>
	</cfif>
	
	<cfif FileExists(vArquivo)>
		<cfif ListLast(vArquivo, ".") eq "pdf">
			<!--- Servir arquivo PDF diretamente sem ler em memória --->
			<cfcontent type="application/pdf" file="#vArquivo#" reset="yes">
		<cfelse>
			<!--- o código dentro do <cfelse> permite que arquivos que não 
			sejam PDFs sejam forçados a serem baixados pelo navegador, 
			garantindo que o usuário possa receber o arquivo em vez de 
			visualizá-lo diretamente na tela. 
			Isso é útil para formatos de arquivo que não são suportados 
			para visualização direta em um navegador. 
			
			A propriedade content-disposition
			com o valor attachment indica que o arquivo deve ser tratado 
			como um anexo. O nome do arquivo que será baixado é determinado por #url.nome#.--->
			<cfheader name="content-disposition" value="attachment; filename=#url.nome#">
			
			<!--- Este comando informa ao navegador que o tipo de 
			conteúdo é desconhecido (application/unknown), e o arquivo 
			a ser baixado é o que está especificado na variável vArquivo. 
			O parâmetro deletefile="no" indica que o arquivo não deve ser excluído após ser servido--->
			<cfcontent type="application/unknown" file="#vArquivo#" deletefile="no">
		</cfif>
	<cfelse>
		<!--- Tratar erro caso o arquivo não exista --->
		<cfoutput>
			<div style="display: flex; justify-content: center; align-items: center; height: 100vh; text-align: center;">
				<div>
					<!--- Ícone de erro (exclamação) com Font Awesome --->
					<i class="fa fa-exclamation-triangle fa-6x" style="color: ##fff;"></i>
					<h1 class="card-title" style="color:##fff; margin-top: 20px;">O arquivo não foi encontrado.</h1>
				</div>
			</div>
		</cfoutput>
	</cfif>

	
</cfif>

<cfcatch>
   <cfdump var="#cfcatch#">
 </cfcatch>
 </cftry>

</body>
</html>
