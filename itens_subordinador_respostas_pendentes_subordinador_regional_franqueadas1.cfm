<cfprocessingdirective pageEncoding ="utf-8">

<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif> 
<cfset Session.E01.observacao = ''>
<cfset Session.E01.numSei = ''>
<cfset Session.E01.Pos_OpcaoBaixa = ''>
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_DR from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery name="qUsuario" datasource="#dsn_inspecao#">
 SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
 FROM Usuarios
 WHERE Usu_Login = '#CGI.REMOTE_USER#'
 GROUP BY Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome
</cfquery>

<cfquery name="rsArea" datasource="#dsn_inspecao#">
	 SELECT Ars_Codigo, Ars_Descricao FROM Areas WHERE Ars_Codigo = '#qUsuario.Usu_Lotacao#'
</cfquery>

<cfquery name="rsItem" datasource="#dsn_inspecao#">
  SELECT RIP_NumInspecao, 
	  RIP_Unidade, 
	  Und_Descricao, 
	  Und_TipoUnidade, 
	  RIP_NumGrupo, 
	  RIP_NumItem, 
	  RIP_Comentario, 
	  RIP_Recomendacoes, 
	  INP_DtInicInspecao, 
	  INP_Responsavel, 
	  Rep_Codigo, 
	  RIP_Valor, 
	  RIP_Caractvlr, 
	  RIP_Falta, 
	  RIP_Sobra, 
	  RIP_EmRisco, 
	  RIP_ReincInspecao, 
	  RIP_ReincGrupo, 
	  RIP_ReincItem, 
	  Itn_TipoUnidade, 
	  Itn_Descricao, 
	  Itn_ImpactarTipos,
	  Itn_PTC_Seq,
	  INP_DtEncerramento,
	  INP_TNCClassificacao, 
	  Grp_Descricao
  FROM Reops 
  INNER JOIN Resultado_Inspecao 
  INNER JOIN Inspecao ON RIP_Unidade = INP_Unidade AND RIP_NumInspecao = INP_NumInspecao 
  INNER JOIN Unidades ON INP_Unidade = Und_Codigo ON Rep_Codigo = Und_CodReop 
  INNER JOIN Grupos_Verificacao 
  INNER JOIN Itens_Verificacao ON Grp_Codigo = Itn_NumGrupo 
  ON RIP_NumGrupo = Itn_NumGrupo AND RIP_NumItem = Itn_NumItem 
  AND right([RIP_NumInspecao], 4) = Itn_Ano and Itn_Ano = Grp_Ano and Itn_TipoUnidade = Und_TipoUnidade 
   AND INP_Modalidade = Itn_Modalidade
  WHERE RIP_NumInspecao='#ninsp#' AND RIP_Unidade='#unid#' AND RIP_NumGrupo= #ngrup# AND RIP_NumItem=#nitem#
</cfquery>

<cfif (Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES') or (Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES') or (Trim(qAcesso.Usu_GrupoAcesso) eq 'SUBORDINADORREGIONAL')>


<cftry>

<cfif isDefined("Form.acao") And (Form.acao is 'Anexar' Or Form.acao is 'Excluir')>

	<cfif isDefined("Form.obs")><cfset Session.E01.obs = Form.obs><cfelse><cfset Session.E01.obs = ''></cfif>
	<cfif isDefined("Form.observacao")><cfset Session.E01.observacao = Form.observacao><cfelse><cfset Session.E01.observacao = ''></cfif>
	<cfif isDefined("Form.NumSEI")><cfset Session.E01.NumSEI = Form.NumSEI><cfelse><cfset Session.E01.NumSEI = ''></cfif>
	<cfif isDefined("Form.h_obs")><cfset Session.E01.h_obs = Form.h_obs><cfelse><cfset Session.E01.h_obs = ''></cfif>
    <cfif isDefined("Form.opcaoBaixa")><cfset Session.E01.Pos_OpcaoBaixa = Form.opcaoBaixa><cfelse><cfset Session.E01.Pos_OpcaoBaixa = ''></cfif>


	 <cfif Form.acao is 'Anexar'>
		<cftry>

		<cffile action="upload" filefield="arquivo" destination="#diretorio_anexos#" nameconflict="overwrite" accept="application/pdf">

		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'SS') & 's'>

		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>
		<!--- O arquivo anexo recebe nome indicando Numero da inspeção, Número da unidade, Número do grupo e número do item ao qual está vinculado --->

		<cfset destino = cffile.serverdirectory & '\' & Form.ninsp & '_' & data & '_' & Right(CGI.REMOTE_USER,8) & '_' & Form.ngrup & '_' & Form.nitem & '.pdf'>


		<cfif FileExists(origem)>

			<cffile action="rename" source="#origem#" destination="#destino#">

			<cfquery datasource="#dsn_inspecao#" name="qVerificaAnexo">
				SELECT Ane_Codigo FROM Anexos
				WHERE Ane_Caminho = <cfqueryparam cfsqltype="cf_sql_varchar" value="#destino#">
			</cfquery>


			<cfif qVerificaAnexo.recordCount eq 0>

				<cfquery datasource="#dsn_inspecao#" name="qVerifica">
				 INSERT INTO Anexos(Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Caminho)
				 VALUES ('#Form.ninsp#','#Form.unid#',#Form.ngrup#,#Form.nitem#,'#destino#')
				</cfquery>

			</cfif>
		</cfif>

		<cfcatch type="any">
			<cfset mensagem = 'Ocorreu um erro ao efetuar esta operação, o campo Arquivo está vazio, Selecione um arquivo no formato PDF'>
			<script>
				alert('<cfoutput>#mensagem#</cfoutput>');
				history.back();
			</script>
			<cfif isDefined("Session.E01")>
			 <cfset StructClear(Session.E01)>
			</cfif>
		
		</cfcatch>

		</cftry>

  </cfif>


	  <!--- Excluir anexo --->
	 <cfif Form.acao is 'Excluir'>
	  <!--- Verificar se anexo existe --->

		<cfquery datasource="#dsn_inspecao#" name="qAnexos">
			SELECT Ane_Codigo, Ane_Caminho FROM Anexos WHERE Ane_Codigo = '#vCodigo#'
		</cfquery>


	  <cfif qAnexos.recordCount Neq 0>

		<!--- Exluindo arquivo do diretório de Anexos --->
		<cfif FileExists(qAnexos.Ane_Caminho)>
			<cffile action="delete" file="#qAnexos.Ane_Caminho#">
		</cfif>


	<!--- Excluindo anexo do banco de dados --->

		<cfquery datasource="#dsn_inspecao#">
		  DELETE FROM Anexos WHERE Ane_Codigo = '#vCodigo#'
		</cfquery>

      </cfif>
   </cfif>
</cfif>

<!--- <cfset area = 'sins'> --->


<cfset evento = 'document.form1.observacao.focus();'>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>
<cfset dtHojeControle = DateFormat(now(),"YYYYMMDD")>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">
	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.Reop" default="#Form.Reop#">
    <cfparam name="URL.dtfinal" default="#form.dtfinal#">
	<cfparam name="URL.dtinic" default="#form.dtinic#"> 
	<cfparam name="URL.cbAreaSubordinados" default="#form.cbAreaSubordinados#">	
    <cfparam name="URL.areaSubordinados" default="#form.areaSubordinados#">	
	<cfparam name="URL.numSEI" default="#form.numSEI#">	     
    
<cfelse>
	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="0">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.DtInic" default="0">
	<cfparam name="URL.dtFinal" default="0">
	<cfparam name="URL.Reop" default="">
	<cfparam name="URL.SE" default="">
    <cfparam name="URL.cbAreaSubordinados" default="">
    <cfparam name="URL.areaSubordinados" default="">
	 <cfparam name="URL.numSEI" default="">	 
</cfif>
<cfquery name="rsTPUnid" datasource="#dsn_inspecao#">
     SELECT Und_Codigo, Und_Descricao, Und_TipoUnidade FROM Unidades WHERE Und_Codigo = '#URL.unid#'
</cfquery>

<cfset lido =  '#CGI.REMOTE_USER#' & " ( " & DateFormat(now(),'DD-MM-YYYY') & " " & TimeFormat(now(),'hh:mm:ss') & " )">
<cfquery datasource="#dsn_inspecao#">
	UPDATE ParecerUnidade SET Pos_Lido ='#lido#' 
	WHERE Pos_Unidade='#url.unid#' AND Pos_Inspecao='#url.ninsp#' AND Pos_NumGrupo=#url.ngrup# AND Pos_NumItem=#url.nitem#
</cfquery>	

<!--- ============= --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#unid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem#
  order by Ane_Codigo
</cfquery>

<!--- ============= --->
<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
  SELECT INP_Responsavel
  FROM Inspecao
  WHERE (INP_NumInspecao = '#URL.Ninsp#')
</cfquery>
<!--- ============= --->
<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT IPT_MatricInspetor, Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND IPT_MatricInspetor = Fun_Matric
  WHERE (IPT_NumInspecao = '#URL.Ninsp#')
</cfquery>

<!--- ============= --->
<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, Pos_Parecer, 
  Pos_DtPosic, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, Pos_DtPrev_Solucao, Pos_OpcaoBaixa, SEI_NumSEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
  FROM ParecerUnidade
  LEFT JOIN Inspecao_SEI ON SEI_Inspecao = Pos_Inspecao and SEI_Unidade = Pos_Unidade and SEI_Grupo =Pos_NumGrupo and SEI_Item = Pos_NumItem
  WHERE Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem# AND Pos_Unidade = '#unid#' AND Pos_Inspecao = '#ninsp#'
</cfquery>
<!--- ============= --->
<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Dir_Descricao, Dir_Codigo, Dir_Sigla
  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>
 <cfset strIDGestor = #url.unid#>
 <cfset strNomeGestor = #rsMod.Und_Descricao#>

<!--- ============= --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>
<!--- ============= --->

<cfif IsDefined("FORM.MM_UpdateRecord") AND FORM.MM_UpdateRecord EQ "form1" And IsDefined("FORM.acao") And Form.acao is "Salvar" and IsDefined('FORM.opcaoBaixa')>
 <cftransaction>
	<!---Cria uma instância do componente Dao--->
	<cfobject component = "CFC/Dao" name = "dao">
	<!---Invoca o metodo  rsUsuarioLogado para retornar dados do usuário logado (rsUsuarioLogado)--->
	<cfinvoke component="#dao#" method="rsUsuarioLogado" returnVariable="rsUsuarioLogado">	
	 <cfquery datasource="#dsn_inspecao#">
	   UPDATE ParecerUnidade SET 
	        Pos_Situacao_Resp = '27'
		  , Pos_opcaoBaixa = '#FORM.opcaoBaixa#'
		  , Pos_Situacao = 'BX'
		  , Pos_Area = '#qUsuario.Usu_Lotacao#'
		  , Pos_NomeArea = '#rsArea.Ars_Descricao#'
		  <cfset situacao = 'BAIXADO'>
	      , Pos_DtPosic = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
		  , Pos_DtUltAtu = CONVERT(char, GETDATE(), 120)
	      , Pos_NomeResp='#CGI.REMOTE_USER#'
		  , Pos_username = '#CGI.REMOTE_USER#'
		  , Pos_Sit_Resp_Antes = #form.scodresp#
		  , Pos_Parecer=
				<cfset aux_obs = Trim(FORM.observacao)>
				<cfset aux_obs = Replace(aux_obs,'"','','All')>
				<cfset aux_obs = Replace(aux_obs,"'","","All")>
				<cfset aux_obs = Replace(aux_obs,'*','','All')>
				<cfset aux_obs = Replace(aux_obs,'>','','All')>
		
				<!---Responsável pela baixa  --->
				<cfset maskmatrusu = trim(rsUsuarioLogado.Login)>
				<cfset maskmatrusu = left(maskmatrusu,12) & mid(maskmatrusu,13,4) & '***' & right(maskmatrusu,1)> 				
				<cfset Responsavel = '#maskmatrusu#' & '\' & '#Trim(rsUsuarioLogado.NomeUsuario)#' & ' (' & '#Trim(rsUsuarioLogado.NomeLotacao)#' & ')'>		 
				<!---Fim da mensagem do Pos_Parecer--->
				<cfset pos_aux_fim =  'Situação: BAIXADO' & CHR(13) & CHR(13) &
									'Responsável: ' & '#Responsavel#' & CHR(13) & CHR(13) &
										RepeatString('-',119)>	
				<cfset pos_aux_fim_gestor =  'Responsável: ' & '#Responsavel#' & CHR(13) & CHR(13) & RepeatString('-',119)>						
				<!---Mensagemdo Pós_parecer--->
				<cfset pos_aux = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Item baixado pela área gestora do Contrato. A responsabilidade pela análise da correta aplicação das cláusulas e penalidades previstas no Contrato caberá à área de atendimento, conforme Fluxo definido para o Processo.' />
				
				<cfset pos_aux_gestor = DateFormat(Now(),"DD/MM/YYYY") & '-' & TimeFormat(Now(),'HH:MM') & '> Registro do Subordinador Regional' & CHR(13) & CHR(13) & 'À SGCIN/SCOI:' /> 
								
				<cfset pos_aux_hist_gestor =  '#pos_aux_gestor#'  & CHR(13) & CHR(13) & '#aux_obs#' & CHR(13) & CHR(13) & CHR(13) & '#pos_aux_fim_gestor#'>
				<cfset pos_aux_hist =  trim(Form.H_obs) & CHR(13) & CHR(13) & '#pos_aux_hist_gestor#' & CHR(13)  & '#pos_aux#' & CHR(13) & CHR(13) & CHR(13) & '#pos_aux_fim#'>
				'#pos_aux_hist#'	
			WHERE Pos_Unidade='#FORM.unid#' AND Pos_Inspecao='#FORM.ninsp#' AND Pos_NumGrupo=#FORM.ngrup# AND Pos_NumItem=#FORM.nitem#
       </cfquery>
     <cfif '#trim(form.numSEI)#' neq ''>
	    <cfset aux_sei = Trim(form.numSEI)>
			<cfset aux_sei = Replace(aux_sei,'.','',"All")>
			<cfset aux_sei = Replace(aux_sei,'/','','All')>
			<cfset aux_sei = Replace(aux_sei,'-','','All')>

	      <cfquery datasource="#dsn_inspecao#" name="rsSEIencontrado">
                 SELECT SEI_NumSEI FROM Inspecao_SEI 
				 WHERE SEI_NumSEI = '#aux_sei#' and SEI_Inspecao = '#FORM.ninsp#' AND SEI_Grupo=#FORM.ngrup# AND SEI_Item=#FORM.nitem# 
		  </cfquery>
         <cfif rsSEIencontrado.recordcount eq 0>
				<cfquery datasource="#dsn_inspecao#">
						INSERT INTO Inspecao_SEI(SEI_Unidade, SEI_Inspecao, SEI_Grupo, SEI_Item, SEI_NumSEI, SEI_dtultatu, SEI_username)
						VALUES('#FORM.unid#', '#FORM.ninsp#', #FORM.ngrup#, #FORM.nitem#, '#aux_sei#', convert(char, getdate(), 120), '#CGI.REMOTE_USER#')
				</cfquery>
	     </cfif>
    </cfif>

          <cfset pos_aux_andamento = '#pos_aux_hist_gestor#' & CHR(13)  & '#pos_aux#' & CHR(13) & CHR(13) & '#pos_aux_fim#' >
         <!---Insert na tabela Andamento--->
            <cfinvoke component="#dao#" method="insertAndamento"  
                NumeroDaInspecao = '#FORM.ninsp#' 
			        	CodigoDaUnidade = '#FORM.unid#' 
			            Grupo = '#FORM.ngrup#' 
			        	Item = '#FORM.nitem#' 
				        CodigoDaSituacaoDoPonto = 27
                        Parecer ='#pos_aux_andamento#'
			        	CodigoUnidadeDaPosicao = '#qUsuario.Usu_Lotacao#'> 

	</cftransaction>				
 </cfif>
<!--- ============= --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#unid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>
<!--- ============= --->

<cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Dir_Descricao, Dir_Codigo, Dir_Sigla
  FROM Unidades INNER JOIN Diretoria ON Unidades.Und_CodDiretoria = Diretoria.Dir_Codigo
  WHERE Und_Codigo = '#URL.Unid#'
</cfquery>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
<cfinclude template="mm_menu.js">

//=========================
function Trim(str)
{
while (str.charAt(0) == ' ')
str = str.substr(1,str.length -1);

while (str.charAt(str.length-1) == ' ')
str = str.substr(0,str.length-1);

return str;
}

//Validação de campos vazios em formulário
function validaForm() {
	if (document.form1.acao.value == 'Salvar'){
		var strmanifesto = document.form1.observacao.value;
		strmanifesto = strmanifesto.replace(/\s/g, '');
		if(strmanifesto == '')
			{
			alert('Caro Usuário, falta o seu Posicionamento no campo "Registro do Gestor"!');
			return false;
			}

		if(strmanifesto.length < 100)
		{
		alert('Caro Usuário, o Registro do Gestor deverá conter no mínimo 100(cem) caracteres');
		return false;
		}
		
		var opcaoBaixa = document.getElementsByName('opcaoBaixa');
		var ischecked_method = false;
		for ( var i = 0; i < opcaoBaixa.length; i++) {
			if(opcaoBaixa[i].checked) {
				ischecked_method = true;
				break;
			}
		}
		if(!ischecked_method)   { 
			alert("Caro Usuário, selecione uma Opção para Baixa!");
			return false;
		}

  }
}
//Função que abre uma página em Popup
function popupPage() {
<cfoutput>  //página chamada, seguida dos parâmetros número, unidade, grupo e item
var page = "itens_unidades_controle_respostas_comentarios.cfm?numero=#ninsp#&unidade=#unid#&numgrupo=#ngrup#&numitem=#nitem#";
</cfoutput>
windowprops = "location=no,"
+ "scrollbars=yes,width=750,height=500,top=100,left=200,menubars=no,toolbars=no,resizable=yes";
window.open(page, "Popup", windowprops);
}
//================
function validacao()
	{
		var ctrl=window.event.ctrlKey;

		var tecla=window.event.keyCode;
/*
		if (ctrl && tecla==67) {
			alert("CTRL+C");
			event.keyCode=0;
			event.returnValue=false;
		}
*/
		if (ctrl && tecla==86) {
			//alert("CTRL+V não permitido!");
			event.keyCode=0;
			event.returnValue=false;
		}
	}
//================
function Mascara_SEI(x)
{
	switch (x.value.length)
	{
		case 5:
		  x.value += ".";
		  break;
		case 12:
		  x.value += "/";
		  break;
		case 17:
		  x.value += "-";
		  break;
	}
}
</script>



</head>
<cfquery name="qResposta" datasource="#dsn_inspecao#">
  SELECT Pos_NumGrupo, Pos_NumItem, Pos_Unidade, Pos_Situacao_Resp, Pos_Situacao, 
  Pos_Parecer, Pos_DtPosic, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, Pos_DtPrev_Solucao, Pos_OpcaoBaixa, SEI_NumSEI, Pos_PontuacaoPonto, Pos_ClassificacaoPonto
  FROM ParecerUnidade
  LEFT JOIN Inspecao_SEI ON SEI_Inspecao = Pos_Inspecao and SEI_Unidade = Pos_Unidade and SEI_Grupo =Pos_NumGrupo and SEI_Item = Pos_NumItem
  WHERE Pos_NumGrupo = #ngrup# AND Pos_NumItem = #nitem# AND Pos_Unidade = '#unid#' AND Pos_Inspecao = '#ninsp#'
</cfquery>



<cfif "#qResposta.Pos_OpcaoBaixa#" neq '0' and "#qResposta.Pos_OpcaoBaixa#" neq ''>
    <script>
     alert("Item baixado com Sucesso!");
	</script>
 </cfif>


<body onLoad="">
<cfset form.acao = ''>
<cfinclude template="cabecalho.cfm">
<table width="99%" height="60%" align="center">
<tr>
	  <td width="74%" valign="top">
<!--- Área de conteúdo   --->
    <form name="form1" method="post" onSubmit="return validaForm()" enctype="multipart/form-data" action="itens_subordinador_respostas_pendentes_subordinador_regional_franqueadas1.cfm">
      <div align="right"><table width="100%" align="center">

	  <tr class="exibir">
            <td colspan="7" bgcolor="eeeeee"><div align="center"><cfoutput><span class="titulo1"><strong>PONTO DE CONTROLE INTERNO POR ÁREA</strong>
                    <input name="unid" type="hidden" id="unid" value="#URL.Unid#">
                    <input name="ninsp" type="hidden" id="ninsp" value="#URL.Ninsp#">
                    <input name="ngrup" type="hidden" id="ngrup" value="#URL.Ngrup#">
                    <input name="nitem" type="hidden" id="nitem" value="#URL.Nitem#">
                    <input name="reop" type="hidden" id="reop" value="#URL.reop#">
					<input name="Situacao" type="hidden" id="Situacao" value="<cfoutput>#Situacao#</cfoutput>">
                    <input type="hidden" name="acao" value="">
                    <input type="hidden" name="anexo" value="">
                    <input type="hidden" name="vCodigo" value="">
                    <input name="dtinic" type="hidden" id="dtinic" value="<cfoutput>#URL.dtinic#</cfoutput>">
                    <input name="dtfinal" type="hidden" id="dtfinal" value="<cfoutput>#URL.dtfinal#</cfoutput>">
				    <input name="cbAreaSubordinados" type="hidden" id="cbAreaSubordinados" value="<cfoutput>#URL.cbAreaSubordinados#</cfoutput>">
                    <input name="areaSubordinados" type="hidden" id="areaSubordinados" value="<cfoutput>#URL.areaSubordinados#</cfoutput>">

 
				  
            </span></cfoutput></div></td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
		  </tr>
		
		  	  <tr class="exibir">
	    <td colspan="7" bgcolor="eeeeee">&nbsp;</td>
	    </tr>
           <tr class="exibir">
	    <td bgcolor="eeeeee">Unidade</td>
	    <td bgcolor="f7f7f7"><cfoutput><strong>#rsMOd.Und_Descricao#</strong></cfoutput></td>
	    <td bgcolor="f7f7f7">Responsável<cfoutput><strong>&nbsp;&nbsp;#qResponsavel.INP_Responsavel#</strong></cfoutput></td>
	    </tr>
          <tr class="exibir">
            <cfif qInspetor.RecordCount lt 2>
              <td bgcolor="eeeeee">Inspetor</td>
              <cfelse>
              <td bgcolor="eeeeee">Inspetores</td>
            </cfif>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td bgcolor="f7f7f7"> -&nbsp;<cfoutput query="qInspetor"><strong>#qInspetor.Fun_Nome#</strong>&nbsp;<cfif qInspetor.currentrow neq qInspetor.recordcount><br> - </cfif></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Nº Avaliação</td>
            <cfset Num_Insp = Left(URL.Ninsp,2) & '.' & Mid(URL.Ninsp,3,4) & '/' & Right(URL.Ninsp,4)>
            <td colspan="6" bgcolor="f7f7f7"><cfoutput><strong>#Num_Insp#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Grupo</td>
            <td colspan="6" bgcolor="f7f7f7"><cfoutput>#URL.Ngrup#</cfoutput><cfoutput><strong> - #rsItem.Grp_Descricao#</strong></cfoutput></td>
          </tr>
          <tr class="exibir">
            <td bgcolor="eeeeee">Item</td>
            <td colspan="6" bgcolor="f7f7f7"><cfoutput>#URL.Nitem#</cfoutput><cfoutput> - #rsItem.Itn_Descricao#</cfoutput></td>
          </tr>
           <tr class="exibir">
			  <td bgcolor="f7f7f7">Relevância</td>
			  <td colspan="6" bgcolor="f7f7f7">
			  <table width="90%" border="0">
				<tr class="exibir">
				  <td>Pontuação </td>
				  <td><strong class="exibir"><cfoutput>#qResposta.Pos_PontuacaoPonto#</cfoutput></strong></td>
				  <td><div align="right">Classificação do Ponto &nbsp;</div></td>
				  <td><strong class="exibir"><cfoutput>#qResposta.Pos_ClassificacaoPonto#</cfoutput></strong></td>
				</tr>
			  </table></td>
			  </tr>		  
<cfoutput>		
<cfset reincSN = "N">
<cfset aux_reincSN = "Nao">
<cfset db_reincInsp = "">
<cfset db_reincGrup = 0>
<cfset db_reincItem = 0>
<cfif rsItem.RIP_ReincGrupo neq 0>
	<cfset reincSN = "S">
	<cfset aux_reincSN = "Sim">
	<cfset db_reincInsp = #trim(rsItem.RIP_ReincInspecao)#>
	<cfset db_reincGrup = #rsItem.RIP_ReincGrupo#>
	<cfset db_reincItem = #rsItem.RIP_ReincItem#>
</cfif>	   
	<cfif reincSN eq 'S'>
		<tr class="red_titulo">
			<td bgcolor="eeeeee">Reincidência</td>
			<td colspan="6" bgcolor="eeeeee">Nº Avaliação:
				<input name="frmreincInsp" type="text" class="form" id="frmreincInsp" size="16" maxlength="10" value="#db_reincInsp#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Grupo:
			<input name="frmreincGrup" type="text" class="form" id="frmreincGrup" size="8" maxlength="5" value="#db_reincGrup#" onKeyPress="numericos(this.value)">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Nº Item:
			<input name="frmreincItem" type="text" class="form" id="frmreincItem" size="7" maxlength="4" value="#db_reincItem#" onKeyPress="numericos(this.value)">
			</strong>		  
			</td>
	</tr>
	</cfif> 
	<cfset tipoimpacto = 'NÃO QUANTIFICADO'>
	<cfset encerrarSN = 'N'>
	<cfset impactofin = 'N'>
	<cfif listFind(#rsItem.Itn_PTC_Seq#,'10')>
	  	<cfset impactofin = 'S'>
		<cfset tipoimpacto = 'QUANTIFICADO'>
	</cfif>		
	<cfset falta = lscurrencyformat(rsItem.RIP_Falta,'Local')>
	<cfset sobra = lscurrencyformat(rsItem.RIP_Sobra,'Local')>
	<cfset emrisco = lscurrencyformat(rsItem.RIP_EmRisco,'Local')>
	<cfset fator = 0>
	<cfset somafaltasobrarisco = (rsItem.RIP_Falta + rsItem.RIP_Sobra + rsItem.RIP_EmRisco)>	   
	<cfset encerrarSN = 'N'>
	<cfif reincSN neq 'S' and rsItem.Und_TipoUnidade neq 12 and rsItem.Und_TipoUnidade neq 16>
		<cfif impactofin eq 'N'>
			<!--- Não tem impacto financeiro --->
			<cfset encerrarSN = 'S'>
		<cfelse>
			<cfset somafaltasobrarisco = numberformat(#somafaltasobrarisco#,9999999999.99)>
			<!--- Tem impacto financeiro --->
			<cfquery name="rsRelev" datasource="#dsn_inspecao#">
				SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
				FROM ValorRelevancia
				WHERE VLR_Ano = '#right(ninsp,4)#'
			</cfquery>
			<cfloop query="rsRelev">
				<cfset fxini = numberformat(rsRelev.VLR_FaixaInicial,9999999999.99)>
				<cfset fxfim = numberformat(rsRelev.VLR_FaixaFinal,9999999999.99)>
				<cfif fxini eq 0.01 and somafaltasobrarisco lte fxfim and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator>
				</cfif>
				<cfif (fxini neq 0.01 and fxfim neq 0.00) and (somafaltasobrarisco gt fxini and somafaltasobrarisco lte fxfim) and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator>
				</cfif>					
				<cfif fxfim eq 0.00 and somafaltasobrarisco gte fxini and fator eq 0>
					<cfset fator = rsRelev.VLR_Fator> 
				</cfif>
			</cfloop>				
			<cfif fator eq 1>
				<cfset encerrarSN = 'S'>
			</cfif>
		</cfif>
	</cfif>		
 	<tr class="exibir">
      <td bgcolor="eeeeee"><div id="impactofin">IMPACTO FINANCEIRO (Valor)</div></td>
      <td colspan="6" bgcolor="eeeeee">
		  <table width="100%" border="0" cellspacing="0" bgcolor="eeeeee">
			<tr class="exibir"><strong>
				<td width="40%" bgcolor="eeeeee"><strong>&nbsp;#tipoimpacto#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Falta(R$):&nbsp;<input name="frmfalta" type="text" class="form" value="#falta#" size="22" maxlength="17" readonly></strong></td>
				<td width="30%" bgcolor="eeeeee"><strong>Sobra(R$):&nbsp;<input name="frmsobra" type="text" class="form" value="#sobra#" size="22" maxlength="17" readonly></strong></td>
				<td width="30%" bgcolor="eeeeee"><strong>Em Risco(R$):&nbsp;<input name="frmemrisco" type="text" class="form" value="#emrisco#" size="22" maxlength="17" readonly></strong></td>
			</tr>
		  </table>		  
	  </td>
    </tr>	  
	</cfoutput>
          <tr class="exibir">
            <td colspan="6" bgcolor="f7f7f7"></td>
          </tr>
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Situação Encontrada:</span></td>
            <td colspan="6" bgcolor="f7f7f7"><span class="exibir">
				<cfset melhoria = replace('#rsItem.RIP_Comentario#','; ' ,';','all')>	
              <textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly><cfoutput>#melhoria#</cfoutput></textarea>
            </span></td>
		  </tr>
		 <tr>
            <td align="center" valign="middle" bgcolor="eeeeee"><span class="titulos">Orientações:</span></td>
            <td colspan="6"><textarea name="H_recom" cols="200" rows="12" wrap="VIRTUAL" class="form" readonly><cfoutput>#rsItem.RIP_Recomendacoes#</cfoutput></textarea></td>
		  </tr>

           <input type="hidden" name="frmResp" value="7"> 
           <input type="hidden" name="obs" value="<cfoutput>#qResposta.Pos_Parecer#</cfoutput>">
          <tr>
            <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><span class="titulos">Hist&oacute;rico:</span> <span class="titulos">Manifesta&ccedil;&atilde;o/An&aacute;lise do Controle Interno</span><span class="titulos">:</span></td>
            <td colspan="6" bgcolor="f7f7f7">
			<textarea name="H_obs" cols="200" rows="40" wrap="VIRTUAL" class="form" readonly><cfoutput>#qResposta.Pos_Parecer#</cfoutput></textarea>
			</td>
          </tr>


          <tr>
          	<td colspan="6" align="left" valign="middle" bgcolor="white"><span class="titulos">
				Senhor gestor escolha uma das Opções de Baixa:</span>
          	</td>
          </tr>
          <tr>

			  <td colspan="6" align="left" valign="middle" bgcolor="white" class="exibir" >
			  <cfset op ="#Session.E01.Pos_OpcaoBaixa#">
          		<input type="radio" id="penalidade_aplicada" name="opcaoBaixa" value="1" <cfif '#op#' eq 1>checked</cfif>>
          		<label for="penalidade_aplicada">Penalidade Aplicada</label>

          		<input type="radio" id="defesa_acatada" name="opcaoBaixa" value="2" style="margin-left:40px" <cfif '#op#' eq 2>checked</cfif>>
          		<label for="defesa_acatada">Defesa Acatada</label>

          		<input type="radio" id="outros" name="opcaoBaixa" value="3" style="margin-left:40px" <cfif '#op#' eq 3>checked</cfif>>
          		<label for="outros">Outros</label>
          	</td>
          </tr>
          <tr>
          	<td colspan="2" align="left" valign="middle" bgcolor="white"><span class="titulos">N° SEI:</span>
          	    <input name="numSEI" id="numSEI" type="text" class="form" wrap="VIRTUAL" onKeyPress="numericos();"
          			onKeyDown="validacao(); Mascara_SEI(this);" size="27" maxlength="20"
          			value="<cfoutput>#Session.E01.NumSEI#</cfoutput>"> 
			</td>
			<cfif "#qResposta.Pos_OpcaoBaixa#" neq '0' and "#qResposta.Pos_OpcaoBaixa#" neq ''>
				<td width="45%" style="color:blue"><strong>ITEM BAIXADO COM SUCESSO!</strong></td>
			</cfif>
          </tr>


          <tr>
          	<td align="center" valign="middle" bgcolor="eeeeee"><span class="exibir"><span class="titulos">Registro do
          				Gestor:</span></span></td>
          	<td colspan="6" bgcolor="f7f7f7"><textarea name="observacao" cols="200" rows="25" 
          			vazio="false" wrap="VIRTUAL" class="form" id="observacao"><cfoutput>#Session.E01.observacao#</cfoutput></textarea></td>
          </tr>
		  
		  <tr>
	        <td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><strong>ANEXOS</strong></td>
            <td colspan="6" align="center" valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
          </tr>
		 
          <tr>
          	<cfset resp=#qResposta.Pos_Situacao_Resp#>
          		<td align="center" valign="middle" bgcolor="eeeeee" class="exibir"><strong>Arquivo:</strong></td>
          		<td colspan="6" bgcolor="eeeeee" class="exibir"><input name="arquivo" class="botao" type="file"
          				size="50">
          			<cfif (resp neq 21)>
          				<input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Anexar'"
          					value="Anexar">
          				<cfelse>
          					<input name="submit" type="submit" class="botao"
          						onClick="document.form1.acao.value='Anexar'" value="Anexar" disabled>
          			</cfif>
          		</td>
		  </tr>
		
	      <tr>
	        <td colspan="6" align="center" valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
		  </tr>
	<cfset cla = 0>
      <cfloop query= "qAnexos">
        <cfif FileExists(qAnexos.Ane_Caminho)>
		 <cfset cla = cla + 1>
		<cfif cla lt 10>
			<cfset cl = '0' & cla & 'º'>
		<cfelse>
			<cfset cl = cla & 'º'>
		</cfif>		
          <tr>
            <td colspan="6" bgcolor="eeeeee" class="form"><cfoutput>#cl# - #ListLast(qAnexos.Ane_Caminho,'\')#</cfoutput></td>
            <td width="3%" align="center" bgcolor="eeeeee"><cfset arquivo = ListLast(qAnexos.Ane_Caminho,'\')>
                <input type="button" class="botao" name="Abrir" value="Abrir" onClick="window.open('abrir_pdf_act.cfm?arquivo=<cfoutput>#arquivo#</cfoutput>','_blank')" />                <div align="left"><cfoutput>
            </cfoutput></div></td>
            <td width="4%" align="center" bgcolor="eeeeee">
			<cfoutput>
		
		        <input name="submit" type="submit" class="botao" onClick="document.form1.acao.value='Excluir';document.form1.vCodigo.value=this.codigo" value="Excluir" codigo="#qAnexos.Ane_Codigo#" disabled>
		
           </cfoutput>
			</td>

            </tr>
        </cfif>
      </cfloop>
	      <tr>
	        <td colspan="6" align="center" valign="middle" bgcolor="eeeeee" class="exibir">&nbsp;</td>
          </tr>
	

<cfoutput>
  <tr>
	 <td colspan="6" bgcolor="eeeeee" class="exibir" align="center"><input name="button" type="button" class="botao" onClick="window.open('itens_subordinador_respostas_pendentes_subordinador_regional_franqueadas.cfm?','_self')" value="Voltar">
     &nbsp;&nbsp;&nbsp;&nbsp;<input name="Submit" type="submit" class="botao" value="Baixar" onClick="document.form1.acao.value='Salvar';" >
	 </td>
  </tr>
 </cfoutput>  	
   </table>
<cfoutput>		
		<input type="hidden" name="MM_UpdateRecord" value="form1">
		<input type="hidden" name="salvar_anexar" value="">
		<input type="hidden" name="scodresp" id="scodresp" value="#qResposta.Pos_Situacao_Resp#">
		<input type="hidden" name="encerrarSN" id="encerrarSN" value="#encerrarSN#">
		<input name="somafaltasobrarisco" type="hidden" id="somafaltasobrarisco" value="#somafaltasobrarisco#">
		<input name="reincideSN" type="hidden" id="reincideSN" value="#reincSN#">		
</cfoutput>
	</form>
<!--- Fim Área de conteúdo --->
  </tr>
</table>
</body>
 <script>
	<cfoutput>
		<!---Retorna true se a data de início da inspeção for maior ou igual a 04/03/2021, data em que o editor de texto foi implantado. Isso evitará que os textos anteriores sejam desformatados--->
		<cfset CouponDate = createDate( 2021, 03, 04 ) />
		<cfif DateDiff( "d", '#rsItem.INP_DtInicInspecao#',CouponDate ) GTE 1>
			<cfset usarEditor = false />
		<cfelse>
			<cfset usarEditor = true />
		</cfif>
		var usarEditor = #usarEditor#;
	</cfoutput>
	if(usarEditor == true){
		//configurações diferenciadas do editor de texto.
		CKEDITOR.replace('Melhoria', {
		width: 1020,
		height: 200,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});

		CKEDITOR.replace('H_recom', {
		width: 1020,
		height: 100,
		toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'styles', items: [ 'Styles'] },
		{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
		{ name: 'insert', items: [ 'Table' ] },		
		{ name: 'insert', items: [ 'HorizontalRule' ] }
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

		});
	}         
</script> 
</html>

<cfcatch>
  <cfdump var="#cfcatch#">
  	<cfif isDefined("Session.E01")>
	   <cfset StructClear(Session.E01)>
	</cfif>
</cfcatch>
</cftry>

<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>

<cfelse>
     <cfinclude template="permissao_negada.htm">
</cfif>
