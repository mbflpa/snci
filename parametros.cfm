<cfset DR = 'Departamento de Governan�a, Riscos e Compliance'>
<cfset siglaDR = 'DCINT'>
<cfset Sigla_Gerencia = 'CCOP'>
<cfset Gerencia = 'COORD CONTR INT OPER/CCOP'>
<cfset rodape = '.: CCOP :. Av. Guararapes, 250 - 3� Andar - Santo Ant�nio - Recife-PE'>
<cfset sto_gerencia = '32050'> <!--- Cinco d�gitos iniciais --->
<cfset cod_dr = '32'>
<cfset Local = SetLocale("Portuguese (Brazilian)")>
<cfset evento = ''>
<cfset Meses = ('Jan, Fev, Mar, Abr, Mai, Jun, Jul, Ago, Set, Out, Nov, Dez')>
<cfset Email_Ginsp = 'peginsp@correios.com.br'>
<cfset pesquisa = "http://intranetpe/gerencias/ginsp/sins/rotinas/formulario_ginsp.cfm">
<cfset vMenu = ''>
<!---<cfset dsn_pesquisa = 'DBPESQUISA_INSPECAO'>--->
<cfset dsn_inspecao = 'DBSNCI'>
<cfset Login_Agencia = 'PE\PEAC'> <!--- Parte inicial do login das ag�ncias (comum a todas as ag�ncias) --->
<cfset Login_CDD = 'PE\PECDD'> <!--- Parte inicial do login dos CDDs (comum a todos os CDDs) --->
<script type="text/javascript" src="ckeditor\ckeditor.js"></script>


<!--- Diret�rio onde ser�o armazenados arquivos anexados a inspe��o --->
<cfset auxsite =  trim(ucase(cgi.server_name))>
<cfif FIND("INTRANETSISTEMASPE", "#auxsite#") >
	<cfset diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_ANEXOS\'>
	<cfset url_relatorio = 'http://intranetsistemaspe/snci/GeraRelatorio/gerador/dsp'>
	<cfset url_csvxls = 'http://intranetsistemaspe/snci/fechamento/'>
<cfelseif FIND("DESENVOLVIMENTOPE", "#auxsite#")>
	<cfset diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
	<cfset url_relatorio = 'http://desenvolvimentope/snci/GeraRelatorio/gerador/dsp'>
	<cfset url_csvxls = 'http://desenvolvimentope/snci/fechamento/'>
<cfelse>
    <cfset diretorio_anexos = '\\sac0424\SISTEMAS\SNCI\SNCI_TESTE\'>
	<cfset url_relatorio = 'http://homologacaope/snci/GeraRelatorio/gerador/dsp'>
	<cfset url_csvxls = 'http://homologacaope/snci/fechamento/'>
</cfif>

<!--- Diret�rio onde ser�o armazenadas as imagens --->
<cfset thisDir = expandPath(".")>
<cfset imagesDirOrientacoes = "#thisDir#/IMAGENS_ORIENTACOES" />
<cfset imagesDirAvaliacoes = "#thisDir#/IMAGENS_AVALIACOES" />
<cfset imagesDirIcones = "#thisDir#/IMAGENS_ICONES" />
<!--- fim: Diret�rio onde ser�o armazenadas as imagens --->

<cfset vRelatorio = 'SNCI'>

<!--- Listas de permiss�es --->
<cfquery name="qSINS" datasource="#dsn_inspecao#">
	SELECT Usu_Login FROM Usuarios WHERE RTrim(Usu_GrupoAcesso) in ('GESTORES','DESENVOLVEDORES','GESTORMASTER', 'INSPETORES', 'ANALISTAS','GOVERNANCA')
</cfquery>

<cfset Lista_SINS = UCase(ValueList(qSINS.Usu_Login))>


<!--- Fun��o de confirma��o de a��o --->
<script language="JavaScript">
function confirmThis(message)
{
	if(confirm(message)) return true;
	return false;
}

</script>
