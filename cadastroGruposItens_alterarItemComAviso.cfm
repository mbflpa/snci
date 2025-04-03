<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="permissao_negada.htm">
	<cfabort>
</cfif>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfif isDefined("form.formAltItem") >
    <cfparam name="form.acao" default="#form.acao#">
    <cfparam name="form.selAltItemAno" default="#form.selAltItemAno#">
    <cfparam name="form.selAltItemGrupo" default="#form.selAltItemGrupo#">
    <cfparam name="form.selAltItem" default="#form.selAltItem#">
    <cfparam name="form.tipos" default="#form.tipos#">
    <cfparam name="form.selAltModalidade" default="#form.selAltModalidade#">
    <cfparam name="form.modalidades" default="#form.modalidades#">
    <cfparam name="form.selAltItemPontuacao" default="#form.selAltItemPontuacao#">
    <cfparam name="form.selAltItemPontuacaoAGF" default="#form.selAltItemPontuacaoAGF#">
	<cfparam name="form.frmptos" default="#form.frmptos#">
	<cfparam name="form.frmptosAGF" default="#form.frmptosAGF#">
<cfelse>
    <cfparam name="form.acao" default="">
    <cfparam name="form.selAltItemAno" default="">
    <cfparam name="form.selAltItemGrupo" default="">
    <cfparam name="form.selAltItem" default="">
    <cfparam name="form.tipos" default="">
    <cfparam name="form.selAltModalidade" default="">
    <cfparam name="form.modalidades" default="">
    <cfparam name="form.selAltItemPontuacao" default="">
    <cfparam name="form.selAltItemPontuacaoAGF" default="">
	<cfparam name="form.frmptos" default="">
	<cfparam name="form.frmptosAGF" default="">
</cfif>
<cfquery name="rsPta" datasource="#dsn_inspecao#">
	SELECT PTC_Seq, PTC_Valor, PTC_Descricao, PTC_Status, PTC_dtultatu, PTC_Username, PTC_Franquia FROM Pontuacao WHERE PTC_Ano = '#form.selAltItemAno#'
</cfquery>
<cfif isDefined("form.acao") and "#form.acao#" eq 'altItem'>
        <cfset tipoUnidadeEncontrado =''>
        <cfset tipoUnidadeNaoExcluir =''>
        <!---Se existirem tipos de unidade a serem excluídos do PLANO DE TESTE, verifica quais deles já fizeram parte de alguma avaliação--->
        <cfif "#form.tiposExcluidos#" neq ''>        
            <cfquery datasource="#dsn_inspecao#" name="rsChecklistUtilizado">
                SELECT  (rtrim(TUN_Descricao) + ':' + convert(varchar,count(RIP_NumInspecao))) + ' avaliações' as totalAvaliacoes, TUN_Codigo FROM Resultado_Inspecao
                INNER JOIN Unidades ON Und_Codigo = RIP_Unidade
                INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
                INNER JOIN Tipo_Unidades ON TUN_Codigo = Und_TipoUnidade
                WHERE Und_TipoUnidade in(#form.tiposExcluidos#)  AND RIP_Ano = '#form.selAltItemAno#'
                AND RIP_NumGrupo = '#form.selAltItemGrupo#' AND RIP_NumItem = '#form.selAltItem#' AND INP_Modalidade = '#form.selAltModalidade#'
                GROUP BY TUN_Codigo,TUN_Descricao
            </cfquery> 
            
            <cfset tipoUnidadeEncontrado = ValueList(rsChecklistUtilizado.totalAvaliacoes,', ')> 
            <cfset tipoUnidadeNaoExcluir = ValueList(rsChecklistUtilizado.TUN_Codigo,',')> 
            
        </cfif>
        
        
        <cftransaction>
				<!---Altera a tabela Itens_Verificacao--->
                <cfquery datasource="#dsn_inspecao#">
                    UPDATE Itens_Verificacao SET Itn_Descricao ='#form.altItemDescricao#' , Itn_Orientacao = '#form.altItemOrientacao#'
                                                , Itn_Amostra = '#form.altItemAmostra#', Itn_Norma = '#form.altItemNorma#'
                                                , Itn_ValorDeclarado = '#form.selCadItemValorDec#', Itn_TipoUnidade = '#form.selAltVisualizacao#'
                                                , Itn_DtUltAtu = CONVERT(char, getdate(), 120) , Itn_UserName = '#qAcesso.Usu_Matricula#'
                                                , Itn_ValidacaoObrigatoria = '#form.selAltValidObrig#' 
                                                , Itn_PreRelato = '#form.altItemPreRelato#' 
                                                , Itn_OrientacaoRelato = '#form.altItemOrientacaoRelato#'

                    WHERE Itn_Ano = '#form.selAltItemAno#' AND Itn_NumGrupo = '#form.selAltItemGrupo#' AND Itn_NumItem = '#form.selAltItem#' 
                </cfquery>
                <!---Altera a tabela TipoUnidade_ItemVerificacao com o valor da pontuação para cada tipo de unidade e ano do item--->               
                <cfloop list="#form.tipos#" index="i">
                    <cfset tipo = "#i#">
                    <cfif (tipo neq 12)>
						<!--- obter a classificacao --->
						<cfquery name="rsPontuacao" datasource="#dsn_inspecao#">
							SELECT TUP_PontuacaoMaxima 
							FROM Tipo_Unidade_Pontuacao 
							WHERE TUP_Ano = '#form.selAltItemAno#' AND TUP_Tun_Codigo in (#form.tipos#)
						</cfquery> 
						<!--- PROPRIAS --->
						<cfset tuiClassificacao = 'Leve'>
						<cfif rsPontuacao.TUP_PontuacaoMaxima is 0 or rsPontuacao.TUP_PontuacaoMaxima is ''>
						   <cfset rsPontuacao.TUP_PontuacaoMaxima = 1>
						   <cfset auxpercentual = 1>
						<cfelse>
						   <cfset auxpercentual = numberFormat((form.selAltItemPontuacao/rsPontuacao.TUP_PontuacaoMaxima)*100,'999')> 
						   <!--- <cfset auxpercentual = numberFormat((9/72)*100,'999')> --->				    
						</cfif>
						<cfif auxpercentual gt 50>
							<cfset tuiClassificacao = 'Grave'> 
						<cfelseif auxpercentual gte 10 and auxpercentual lte 50>
							<cfset tuiClassificacao = 'Mediana'> 
						<cfelseif auxpercentual lt 10>
							<cfset tuiClassificacao = 'Leve'> 
						</cfif>
						<!--- FIM - PROPRIAS --->					
						<cfset  auxini = 1>
						<cfset  auxfim = len(trim(#form.frmptos#))>
						<cfloop condition="auxini lt auxfim">
						   <cfif auxini is 1>
							 <cfset TUIPontuacaoDesc =  mid(form.frmptos,auxini,2)>
						   <cfelse>
							 <cfset TUIPontuacaoDesc = TUIPontuacaoDesc & ',' & mid(form.frmptos,auxini,2)>
						   </cfif>
						 <cfset  auxini = auxini + 2>
						</cfloop>						
                        <cfquery datasource="#dsn_inspecao#">
                            UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = '#form.selAltItemPontuacao#', TUI_Pontuacao_Seq = '#TUIPontuacaoDesc#', TUI_Classificacao = '#tuiClassificacao#'
                            WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = '#form.selAltItem#'
                        </cfquery>
                    <cfelse>
						<!--- obter a classificacao --->
						<cfquery name="rsPontuacao" datasource="#dsn_inspecao#">
							SELECT TUP_PontuacaoMaxima 
							FROM Tipo_Unidade_Pontuacao 
							WHERE TUP_Ano = '#form.selAltItemAno#' AND TUP_Tun_Codigo in (#form.tipos#)
						</cfquery> 					
						<!--- FRANQUIAS --->
						<cfset tuiClassificacaoAGF = 'Leve'>
						<cfif rsPontuacao.TUP_PontuacaoMaxima is 0 or rsPontuacao.TUP_PontuacaoMaxima is ''>
						   <cfset rsPontuacao.TUP_PontuacaoMaxima = 1>
						   <cfset auxpercentual = 1>
						<cfelse>
						   <cfset auxpercentual = numberFormat((form.selAltItemPontuacaoAGF/rsPontuacao.TUP_PontuacaoMaxima)*100,'999')> 
						   <!--- <cfset auxpercentual = numberFormat((9/72)*100,'999')> --->				    
						</cfif>
						<cfif auxpercentual gt 50>
							<cfset tuiClassificacaoAGF = 'Grave'> 
						<cfelseif auxpercentual gte 10 and auxpercentual lte 50>
							<cfset tuiClassificacaoAGF = 'Mediana'> 
						<cfelseif auxpercentual lt 10>
							<cfset tuiClassificacaoAGF = 'Leve'> 
						</cfif>
						<!--- FIM - FRANQUIAS --->					
						<!---  obter TUIPontuacaoDesc --->
						<cfset  auxini = 1>
						<cfset  auxfim = len(trim(#form.frmptos#))>
						<cfloop condition="auxini lt auxfim">
						   <cfif auxini is 1>
							 <cfset TUIPontuacaoDesc =  mid(form.frmptos,auxini,2)>
						   <cfelse>
							 <cfset TUIPontuacaoDesc = TUIPontuacaoDesc & ',' & mid(form.frmptos,auxini,2)>
						   </cfif>
						 <cfset  auxini = auxini + 2>
						</cfloop>					
						<!--- fim TUIPontuacaoDesc  --->
		
					    <cfset auxptodesc = TUIPontuacaoDesc & ',' & form.frmptosAGF>			
		
                        <cfquery datasource="#dsn_inspecao#">
                            UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = '#form.selAltItemPontuacaoAGF#', TUI_Pontuacao_Seq = '#auxptodesc#', TUI_Classificacao = '#tuiClassificacaoAGF#'
                            WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = '#form.selAltItem#'
                        </cfquery>
                    </cfif>
                </cfloop>
                 
                <!---Se existirem tipos de unidade a serem excluídos do PLANO DE TESTE--->
                <cfif "#form.tiposExcluidos#" neq ''> 
                    <cfquery datasource="#dsn_inspecao#" >
                        DELETE FROM TipoUnidade_ItemVerificacao 
                         WHERE TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = #form.selAltItemGrupo# 
                                AND TUI_ItemVerif = #form.selAltItem# AND TUI_Modalidade = '#form.selAltModalidade#'
                            <cfif "#form.tiposExcluidos#" neq ''>
                                AND TUI_TipoUnid in(#form.tiposExcluidos#)
                            </cfif>
                            <cfif "#tipoUnidadeNaoExcluir#" neq ''>
                                AND TUI_TipoUnid not in(#tipoUnidadeNaoExcluir#)
                            </cfif>
                    </cfquery>
                </cfif>
                <!---Se existirem tipos de unidade a serem incluídos do PLANO DE TESTE--->
                <cfif "#form.tiposIncluidos#" neq ''>
                    <cfloop list="#form.tiposIncluidos#" index="i">
                        <cfset tipo = "#i#">
                        <cfquery datasource="#dsn_inspecao#">
                            INSERT INTO TipoUnidade_ItemVerificacao (TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ano,TUI_Ativo)
                            VALUES('#form.selAltModalidade#',#tipo#,#form.selAltItemGrupo#,#form.selAltItem#,CONVERT(char, getdate(), 120),'#qAcesso.Usu_Matricula#',#form.selAltItemAno#,0) 
                        </cfquery>
                        <!---Altera ao campo TUI_Pontuacao tabela TipoUnidade_ItemVerificacao para cada tipo de unidade e ano do item--->
							<cfif (tipo neq 12)>
							<!--- obter a classificacao --->
							<cfquery name="rsPontuacao" datasource="#dsn_inspecao#">
								SELECT TUP_PontuacaoMaxima 
								FROM Tipo_Unidade_Pontuacao 
								WHERE TUP_Ano = '#form.selAltItemAno#' AND TUP_Tun_Codigo in (#form.tipos#)
							</cfquery> 
							<!--- PROPRIAS --->
							<cfset tuiClassificacao = 'Leve'>
							<cfif rsPontuacao.TUP_PontuacaoMaxima is 0 or rsPontuacao.TUP_PontuacaoMaxima is ''>
							   <cfset rsPontuacao.TUP_PontuacaoMaxima = 1>
							   <cfset auxpercentual = 1>
							<cfelse>
							   <cfset auxpercentual = numberFormat((form.selAltItemPontuacao/rsPontuacao.TUP_PontuacaoMaxima)*100,'999')> 
							   <!--- <cfset auxpercentual = numberFormat((9/72)*100,'999')> --->				    
							</cfif>
							<cfif auxpercentual gt 50>
								<cfset tuiClassificacao = 'Grave'> 
							<cfelseif auxpercentual gte 10 and auxpercentual lte 50>
								<cfset tuiClassificacao = 'Mediana'> 
							<cfelseif auxpercentual lt 10>
								<cfset tuiClassificacao = 'Leve'> 
							</cfif>
							<!--- FIM - PROPRIAS --->					
							<cfset  auxini = 1>
							<cfset  auxfim = len(trim(#form.frmptos#))>
							<cfloop condition="auxini lt auxfim">
							   <cfif auxini is 1>
								 <cfset TUIPontuacaoDesc =  mid(form.frmptos,auxini,2)>
							   <cfelse>
								 <cfset TUIPontuacaoDesc = TUIPontuacaoDesc & ',' & mid(form.frmptos,auxini,2)>
							   </cfif>
							 <cfset  auxini = auxini + 2>
							</cfloop>	
													
                            <cfquery datasource="#dsn_inspecao#">
                                UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selAltItemPontuacao#, TUI_Pontuacao_Seq = '#TUIPontuacaoDesc#', TUI_Classificacao = '#tuiClassificacao#'
                                WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = '#form.selAltItem#'
                            </cfquery>
                        <cfelse>
							<!--- obter a classificacao --->
							<cfquery name="rsPontuacao" datasource="#dsn_inspecao#">
								SELECT TUP_PontuacaoMaxima 
								FROM Tipo_Unidade_Pontuacao 
								WHERE TUP_Ano = '#form.selAltItemAno#' AND TUP_Tun_Codigo in (#form.tipos#)
							</cfquery> 					
							<!--- FRANQUIAS --->
							<cfset tuiClassificacaoAGF = 'Leve'>
							<cfif rsPontuacao.TUP_PontuacaoMaxima is 0 or rsPontuacao.TUP_PontuacaoMaxima is ''>
							   <cfset rsPontuacao.TUP_PontuacaoMaxima = 1>
							   <cfset auxpercentual = 1>
							<cfelse>
							   <cfset auxpercentual = numberFormat((form.selAltItemPontuacaoAGF/rsPontuacao.TUP_PontuacaoMaxima)*100,'999')> 
							   <!--- <cfset auxpercentual = numberFormat((9/72)*100,'999')> --->				    
							</cfif>
							<cfif auxpercentual gt 50>
								<cfset tuiClassificacaoAGF = 'Grave'> 
							<cfelseif auxpercentual gte 10 and auxpercentual lte 50>
								<cfset tuiClassificacaoAGF = 'Mediana'> 
							<cfelseif auxpercentual lt 10>
								<cfset tuiClassificacaoAGF = 'Leve'> 
							</cfif>
							<!--- FIM - FRANQUIAS --->					
							<!---  obter TUIPontuacaoDesc --->
							<cfset  auxini = 1>
							<cfset  auxfim = len(trim(#form.frmptos#))>
							<cfloop condition="auxini lt auxfim">
							   <cfif auxini is 1>
								 <cfset TUIPontuacaoDesc =  mid(form.frmptos,auxini,2)>
							   <cfelse>
								 <cfset TUIPontuacaoDesc = TUIPontuacaoDesc & ',' & mid(form.frmptos,auxini,2)>
							   </cfif>
							 <cfset  auxini = auxini + 2>
							</cfloop>					
							<!--- fim TUIPontuacaoDesc  --->
			
							<cfset auxptodesc = TUIPontuacaoDesc & ',' & form.frmptosAGF>	
						
                            <cfquery datasource="#dsn_inspecao#">
                                UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selAltItemPontuacaoAGF#, TUI_Pontuacao_Seq = '#auxptodesc#', TUI_Classificacao = '#tuiClassificacaoAGF#'
                                WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selAltItemAno#' AND TUI_GrupoItem = '#form.selAltItemGrupo#' AND TUI_ItemVerif = '#form.selAltItem#'
                            </cfquery>
                        </cfif>

                    </cfloop>
                </cfif>
        </cftransaction>

        <script type="text/javascript"> 
            <cfoutput>var tipoUnidadeEncontrado = '#tipoUnidadeEncontrado#';</cfoutput>
            if(tipoUnidadeEncontrado == ''){
                alert('Item alterado com sucesso!');
            }else{
                alert('Existem avalições cadastradas no SNCI para o item selecionado e tipo(s) de unidade desmarcado(s) no PLANO DE TESTE:\n\n' + tipoUnidadeEncontrado + '\n\nEsta alteração não foi realizada.');
                alert('Demais alterações realizadas com sucesso!');
            }                
        </script>
</cfif>

<cfif isDefined("form.acao") and "#form.acao#" eq 'excItem'>
    <cftransaction>
        <cfquery datasource="#dsn_inspecao#" >
            DELETE FROM TipoUnidade_ItemVerificacao 
            WHERE TUI_Ano = '#form.selAltItemAno#' and TUI_GrupoItem = #form.selAltItemGrupo# 
                and TUI_ItemVerif =#form.selAltItem#  
        </cfquery>

        <cfquery datasource="#dsn_inspecao#" >
            DELETE FROM Itens_Verificacao 
            WHERE Itn_Ano = '#form.selAltItemAno#' and Itn_NumGrupo = #form.selAltItemGrupo#
                  AND Itn_NumItem = #form.selAltItem#
        </cfquery>
    </cftransaction>
    <script type="text/javascript">           
        alert('Item excluído com sucesso!');
        window.open('cadastroGruposItens.cfm','_self');           
    </script
></cfif>

<cfset anoInic = year(Now())> 							
<cfset anoFinal = anoInic + 1>
                                            
<cfquery datasource="#dsn_inspecao#" name="rsAnoFiltro">
    SELECT DISTINCT Itn_Ano FROM Itens_Verificacao 
    WHERE Itn_Ano BETWEEN #anoInic# AND #anoFinal#
    ORDER BY Itn_Ano
</cfquery>

<cfif isDefined("form.selAltItemAno") and '#form.selAltItemAno#' neq ''>
    <cfquery datasource="#dsn_inspecao#" name="rsGrupoFiltro">
        SELECT * FROM Grupos_Verificacao WHERE Grp_Ano = '#form.selAltItemAno#'
    </cfquery>
</cfif>

<cfif isDefined("form.selAltItemGrupo") and '#form.selAltItemGrupo#' neq ''>
     <cfquery datasource="#dsn_inspecao#" name="rsItemFiltro">
        SELECT DISTINCT Itn_NumItem, Itn_Descricao FROM Itens_Verificacao 
        WHERE Itn_Ano = '#form.selAltItemAno#' AND Itn_NumGrupo = '#form.selAltItemGrupo#' 
    </cfquery>
</cfif>

<cfif isDefined("form.selAltItem") and '#form.selAltItem#' neq ''>
    <cfquery datasource="#dsn_inspecao#" name="rsChecklist">
        SELECT * FROM Itens_Verificacao 
        INNER JOIN TipoUnidade_ItemVerificacao ON TUI_GrupoItem = Itn_NumGrupo AND TUI_ItemVerif = Itn_NumItem AND TUI_Ano = Itn_Ano
        WHERE TUI_Ano = '#form.selAltItemAno#' AND Itn_NumGrupo = #form.selAltItemGrupo# AND Itn_NumItem = #form.selAltItem# 
    </cfquery>
    <cfquery dbtype="query" name="rsModFiltro">
        SELECT DISTINCT TUI_Modalidade FROM rsChecklist
    </cfquery>
</cfif>

<cfif isDefined("form.selAltModalidade") and '#form.selAltModalidade#' neq ''>
    <!--- Verifica se o item selecionado já faz parte de alguma avaliação para impedir exclusão--->
    <cfquery datasource="#dsn_inspecao#" name="rsChecklistJaUtilizado">
                SELECT  RIP_NumInspecao FROM Resultado_Inspecao
                INNER JOIN Unidades ON Und_Codigo = RIP_Unidade
                INNER JOIN Inspecao ON INP_NumInspecao = RIP_NumInspecao
                WHERE RIP_Ano = '#form.selAltItemAno#' AND RIP_NumGrupo = '#form.selAltItemGrupo#' 
                      AND RIP_NumItem = '#form.selAltItem#' AND INP_Modalidade = '#form.selAltModalidade#'
    </cfquery>
    <!--- Fim da verifica se o item seleciona já faz parte de alguma avaliação para impedir exclusão--->


    <cfquery dbtype="query" name="rsItemFiltrado">
        SELECT * FROM rsChecklist 
        WHERE TUI_Modalidade = '#form.selAltModalidade#'
    </cfquery>

    <cfquery dbtype="query" name="rsTiposFiltrado">
        SELECT DISTINCT TUI_TipoUnid FROM rsItemFiltrado
    </cfquery>

    <cfset tipos = ValueList(rsTiposFiltrado.TUI_TipoUnid)>

</cfif>


<cfquery name="qTipoUnidades" datasource="#dsn_inspecao#">
    SELECT * FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery>



<html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <script type="text/javascript" src="ckeditor/ckeditor.js"></script>
       

    <style type="text/css">    
        .tituloDivAltItem{
            padding:5px;
            position:relative;
            top: -19px;
            background: #003366;
            border: 1px solid #fff;
        }
    </style>

    <script type="text/javascript"> 

        
        //muda a cor dos tipos e modalidades selecionados
        function mudaCorCheckedAlt(b){
            (b.checked==true) ? b.parentNode.style.background='green' : b.parentNode.style.background='none';
            (b.checked==true) ? b.parentNode.style.border='1px solid #fff' : b.parentNode.style.border='1px solid transparent';
        }

         //muda a cor dos tipos Alterados
        function mudaCorCheckedTipo(b){
            <cfoutput>
                <cfif isDefined("form.selAltItem") and '#form.selAltItem#' neq ''>
                    var tipo = '#tipos#';
                </cfif>
            </cfoutput>

            if(tipo.indexOf(b.value) == -1){//se não estiver na lista tipo
                if(b.checked==false){//se não estiver marcado
                    b.parentNode.style.background='none';
                    b.parentNode.style.border='1px solid transparent';
                }else{//se estiver marcado
                    b.parentNode.style.background='blue';
                    b.parentNode.style.border='1px solid #fff'
                }      
            }else{//se estiver na lista tipo
                 if(b.checked==false){//se não estiver marcado
                    b.parentNode.style.background='red';
                    b.parentNode.style.border='1px solid #fff'         
                 }else{//se estiver marcado
                    b.parentNode.style.background='green';
                    b.parentNode.style.border='1px solid #fff'    
                 }
               
            }         
        }

        function selectChecbox(nomeChecbox){
            var checkboxes = document.getElementsByName(nomeChecbox);  
            var numberOfCheckedItems = 0; 
            for(var i = 0; i < checkboxes.length; i++){
                if(checkboxes[i].checked){ 
                   numberOfCheckedItems++;  
                   if(numberOfCheckedItems > 1){
                     selecionados = selecionados + "," + checkboxes[i].value;
                   }
                   if(numberOfCheckedItems == 1){
                     selecionados = checkboxes[i].value;
                   }
                }  
            }
            if(numberOfCheckedItems == 0){
              selecionados ='';  
            }
            return selecionados;
        }


        var tiposSelecionados = '';
        var modalidadesSelecionadas = '';
        

        function valida_formAltItem(){
            tiposSelecionados = selectChecbox("selAltItemTipoUnidade");

            var frm = document.getElementById('formAltItem');

            if (frm.altItemDescricao.value == '') {
				alert('Informe uma descrição para item.');
				frm.altItemDescricao.focus();
				return false;
			}


            if (CKEDITOR.instances.altItemOrientacao.getData()== '') {
				alert('Informe "COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS" para o item.');
				CKEDITOR.instances.altItemOrientacao.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemOrientacao.getData()== '') {
				alert('Informe "COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS" para o item.');
				CKEDITOR.instances.altItemOrientacao.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemAmostra.getData()== '') {
				alert('Informe a Amostra para o item.');
				CKEDITOR.instances.altItemAmostra.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemNorma.getData()== '') {
				alert('Informe a Norma para o item.');
				CKEDITOR.instances.altItemNorma.focus();
				return false;
			}

            if (CKEDITOR.instances.altItemPreRelato.getData()== '') {
				alert('Informe um modelo de relato para o item.');
				CKEDITOR.instances.altItemPreRelato.focus();
				return false;
			}
            
            if (CKEDITOR.instances.altItemOrientacaoRelato.getData()== '') {
				alert('Informe uma orientação para o órgão.');
				CKEDITOR.instances.altItemOrientacaoRelato.focus();
				return false;
			}

            if (tiposSelecionados == '') {
				alert('Selecione, pelo menos, 01(um) tipo de unidade para a qual o item será aplicado.');
				return false;
			}

            if (frm.selAltItemPontuacao.value == '' && isVisible(document.getElementById('selAltItemPontuacao'))==true) {
				alert('Informe a Pontuação para o item.\n\nObs.: Pode inserir manualmente ou utilizando "Calculadora de Pontuação".');
                frm.selAltItemPontuacao.focus();
				return false;
			}  

            if (frm.selAltItemPontuacaoAGF.value == '' && isVisible(document.getElementById('selAltItemPontuacaoAGF'))==true) {
				alert('Informe a Pontuação do item para AGF.\n\nObs.: Pode inserir manualmente ou utilizando a "Calculadora de Pontuação".');
                frm.selAltItemPontuacaoAGF.focus();
				return false;
			}

            function inArray(array, elem){
                var len = array.length;
                for(var i = 0 ; i < len;i++){
                    if(array[i] == elem){return i;}
                }
                return -1;
            } 

            if(window.confirm('Deseja alterar este Item?')){  
                frm.tipos.value=tiposSelecionados;

                <cfoutput>
                    var tiposCadastrados = '#tipos#';
                    var tiposCadastrados = tiposCadastrados.split(',');
                    tiposSelecionados = tiposSelecionados.split(',');
                </cfoutput>
                var tiposExcluidos ='';  
                var tiposIncluidos ='';   
                for(var i = 0; i < tiposCadastrados.length; i++){
                   if(inArray(tiposSelecionados, tiposCadastrados[i])==-1 ){
                       if(tiposExcluidos != ''){
                            tiposExcluidos=tiposCadastrados[i] + ","+ tiposExcluidos;     
                       }else{
                            tiposExcluidos=tiposCadastrados[i];  
                       }
                        
                   }
                }
                for(var i = 0; i < tiposSelecionados.length; i++){
                   if(inArray(tiposCadastrados, tiposSelecionados[i])==-1 ){
                       if(tiposIncluidos != ''){
                            tiposIncluidos=tiposSelecionados[i] + ","+ tiposIncluidos;     
                       }else{
                            tiposIncluidos=tiposSelecionados[i];  
                       }
                        
                   }
                }
          
                frm.acao.value = 'altItem';
                frm.tiposExcluidos.value = tiposExcluidos;
                frm.tiposIncluidos.value = tiposIncluidos;
			    aguarde();
                setTimeout('document.getElementById("formAltItem").submit();',2000);
                return true;	
            }else{
                return false;
            }

        }  

        function valida_formExcItem(){
            var frm = document.getElementById('formAltItem');
            var quantUtil = 0;
            <cfoutput>
                <cfif isDefined("form.selAltModalidade") and '#form.selAltModalidade#' neq ''>
                   quantUtil = '#rsChecklistJaUtilizado.recordcount#';
                </cfif>
            </cfoutput>
           
            if(quantUtil !=0){
                alert('Foram localizados registros de avaliação para o Item.\n\n A exclusão não poderá ser realizada!')
                return false;
            }
           
            if(quantUtil == 0){
                if(window.confirm('Confirma a exclusão definitiva do item?\n\nAtenção: O item será excluído do Plano de Teste de todas as modalidades de Avaliação!')){
                    frm.acao.value = 'excItem';
                    aguarde();
                    setTimeout('document.getElementById("formAltItem").submit();',2000);
                    return true;
                }else{
                    return false;
                }
            }


        }

        

        //script para calculadora de pontuação

        // apos load muda cor dos tipos de unidades conforme item selecionado
        window.onload = function(){
            temAGF();
            if(document.forms['formAltItem']){
                var all = document.forms['formAltItem'].elements;
                for(x=0;x<all.length;x++){
                    mudaCorCheckedAlt(all[x]);
                }
            }
        };
        function temAGF(){
            
            tiposSelecionados = selectChecbox("selAltItemTipoUnidade"); 
            tiposSelecionadosList = tiposSelecionados.split(',')
  
            if(tiposSelecionados.indexOf("12") != -1 && tiposSelecionadosList.length >=1){
                document.getElementById('checkPontuacaoAGFdiv').style.visibility = 'visible';
                document.getElementById('checkPontuacaoAGFdiv').style.display = 'block';
                document.getElementById('totalDiv').style.visibility = 'visible';
                document.getElementById('totalDiv').style.position = 'relative';
                document.getElementById('totalAGFdiv').style.visibility = 'visible';
                document.getElementById('selAltItemPontuacaoDiv').style.position = 'relative'; 
                document.getElementById('selAltItemPontuacaoAGFdiv').style.visibility = 'visible'; 
                document.getElementById('selAltItemPontuacaoDiv').style.visibility = 'visible';
                document.getElementById('selAltItemPontuacaoDiv').style.position = 'relative';
                
            }
            
            if(tiposSelecionados.indexOf("12") != -1 && tiposSelecionadosList.length==1){
                document.getElementById('checkPontuacaoAGFdiv').style.visibility = 'visible';
                document.getElementById('checkPontuacaoAGFdiv').style.display = 'block';                
                document.getElementById('totalAGFdiv').style.visibility = 'visible';
                document.getElementById('totalDiv').style.visibility = 'hidden';
                document.getElementById('totalDiv').style.position = 'absolute';
                document.getElementById('selAltItemPontuacaoAGFdiv').style.visibility = 'visible'; 
                document.getElementById('selAltItemPontuacaoDiv').style.visibility = 'hidden';
                document.getElementById('selAltItemPontuacaoDiv').style.position = 'absolute';

            }
            
            if(tiposSelecionados.indexOf("12") == -1){
                document.getElementById('checkPontuacaoAGFdiv').style.visibility = 'hidden';
                document.getElementById('checkPontuacaoAGFdiv').style.display = 'none';  
                document.getElementById('totalAGFdiv').style.visibility = 'hidden';
                document.getElementById('totalDiv').style.visibility = 'visible';
                document.getElementById('totalDiv').style.position = 'relative';
                document.getElementById('selAltItemPontuacaoAGFdiv').style.visibility = 'hidden';
                document.getElementById('selAltItemPontuacaoDiv').style.visibility = 'visible'; 
                document.getElementById('selAltItemPontuacaoDiv').style.position = 'relative';             
            }
        }

        var isVisible = function(el){
                // returns true iff el and all its ancestors are visible
                return el.style.display !== 'none' && el.style.visibility !== 'hidden'
                && (el.parentElement? isVisible(el.parentElement): true)
            };


        function SomenteNumero(e){
            var tecla=(window.event)?event.keyCode:e.which;   
            if((tecla>47 && tecla<58)) return true;
            else{
                if (tecla==8 || tecla==0) return true;
            else  return false;
            }
        }

        var ptTotal=0;        
        function calcularPontuacao(){
            ptTotal = 0         
            var pontosSelecionados = selectChecbox("checkPontuacao");
            pontosSelecionados = pontosSelecionados.split(',');           
            for(var i = 0; i < pontosSelecionados.length; i++){
                ptTotal= ptTotal + (1*pontosSelecionados[i]);     
            }                     
            document.getElementById('pontuacaoCalculada').value = ptTotal;  
            document.getElementById('pontuacaoCalculadaAGF').value = ptTotal +(document.getElementById('checkPontuacaoAGF').value *1); 
        }

        function inserePontuacao(){
            if (document.getElementById('checkPontuacaoAGF').value =="" && isVisible(document.getElementById('checkPontuacaoAGF'))==true) {
				alert('Selecione a pontuação adicional para a AGF.');
                document.getElementById('checkPontuacaoAGF').focus();
				return false;
			}else{           
                document.getElementById('selAltItemPontuacao').value = ptTotal; 
                document.getElementById('selAltItemPontuacaoAGF').value = ptTotal + (document.getElementById('checkPontuacaoAGF').value *1); 
                document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'hidden';
                document.getElementById("calculadoraPontuacaoAlt").style.display = 'none';
            }
        }

        function mostraCalculadora(){
            if (isVisible(document.getElementById('calculadoraPontuacaoAlt'))==true) {
                document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'hidden';
                document.getElementById("calculadoraPontuacaoAlt").style.display = 'none';
            }else{
                document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'visible';
                document.getElementById("calculadoraPontuacaoAlt").style.display = 'block';
                document.getElementById("calculadoraPontuacaoAlt").focus();
            }
            
        }

        function fechaCalculadora(){
            document.getElementById("calculadoraPontuacaoAlt").style.visibility = 'hidden';
            document.getElementById("calculadoraPontuacaoAlt").style.display = 'none';
            
        }
        //Fim script para calculadora de pontuação

        function mostraAvisoAlteracao(){
            if (isVisible(document.getElementById('avisoAlteracao'))==true) {
                document.getElementById("avisoAlteracao").style.visibility = 'hidden';
                document.getElementById("avisoAlteracao").style.display = 'none';
            }else{
                document.getElementById("avisoAlteracao").style.visibility = 'visible';
                document.getElementById("avisoAlteracao").style.display = 'block';
                document.getElementById("avisoAlteracao").focus();
            }
            
        }

        function getPosicaoElemento(elemID){
            var offsetTrail = document.getElementById(elemID);
            var offsetLeft = 0;
            var offsetTop = 0;
            while (offsetTrail) {
                offsetLeft += offsetTrail.offsetLeft;
                offsetTop += offsetTrail.offsetTop;
                offsetTrail = offsetTrail.offsetParent;
            }
            if (navigator.userAgent.indexOf("Mac") != -1 && 
                typeof document.body.leftMargin != "undefined") {
                offsetLeft += document.body.leftMargin;
                offsetTop += document.body.topMargin;
            }
            return {left:offsetLeft, top:offsetTop};
        }

        function PosicaoElemento(elemento, alvo){
            var top = getPosicaoElemento(elemento.id).top - 284 + 'px';
            var left = getPosicaoElemento(elemento.id).left + 67 + 'px';
            document.getElementById(alvo).style.top=top;
            document.getElementById(alvo).style.left=left;
        }
//=============================
function selecptos(a){
//	alert(a);
    var frm = document.getElementById('formAltItem');
	var aux = frm.frmptos.value;
    frm.frmptos.value = '';
	if (aux == '') 
	   {
	   aux = a;
	   frm.frmptos.value = aux;
	//   	   alert('linha114 ' + aux);
	   } 
	else 
	   {
	   if (aux == a) 
	   {
	   aux = '';
	   frm.frmptos.value = aux;
	//   	alert('linha122 ' + aux);
	   } 
	   else 
	   {
	    var posic = aux.indexOf(a); 
		var tam = aux.length;
		//alert('posicao: ' + posic + ' tamanho: ' + tam);
	    if (posic < 0) 
	    {
		 aux = aux + a;
		 frm.frmptos.value = aux;
	  // 	   alert('linha134 ' + aux);
		} 
		else 
		  {
		   if (posic == 0)
		   {
		    aux = aux.substring(2, tam);
			frm.frmptos.value = aux;
	  //	   alert('linha142 ' + aux);
		   } 
		   else 
		     {
		      if ((posic + 1) == tam) 
			  {
			   aux = aux.substring(0, (posic - 1));
			   frm.frmptos.value = aux;
			//   alert('linha150 ' + aux);
			  } 
			  else 
			      {
				    aux = aux.substring(0, (posic)) + aux.substring((posic + 2), tam);
					frm.frmptos.value = aux;
		   	    //    alert('linha156 ' + aux);
				  }
				 // aux = '';
		     }
		  }
	   }
	 }
	
//	alert(aux);
//    alert('valor salvo: ' + frm.frmptos.value);
}
//=============================
function selecptosAGF(a){
    var frm = document.getElementById('formAltItem');
    frm.frmptosAGF.value = a;
}
    </script>

 
</head>
    <body id="main_body" style="background:#fff;" >

        <div align="left" >
            <form id="formAltItem" nome="formAltItem" enctype="multipart/form-data" method="post" >
                <input type="hidden" value="" id="acao" name="acao">
                <input type="hidden" value="" id="tipos" name="tipos"> 
                <input type="hidden" value="" id="tiposExcluidos" name="tiposExcluidos">
                <input type="hidden" value="" id="tiposIncluidos" name="tiposIncluidos">
				<input type="hidden" value="" id="frmptos" name="frmptos">
				<input type="hidden" value="" id="frmptosAGF" name="frmptosAGF">

                    <div align="left" style="padding:10px;border:1px solid #fff;width:835px;">
                        <div align="left">
								<span class="tituloDivAltItem" >Filtro</span>
						</div>
                        <div align="left" style="">
                            <div style="margin-bottom:10px;float:left;margin-right:20px;">
                                        <label  for="selAltItemAno" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">ANO:</label>
                                        <div ></div>	
                                        <select name="selAltItemAno" id="selAltItemAno" onChange="if(this.value!=''){aguarde(); setTimeout('javascript:formAltItem.submit();',2000)}else{window.open('cadastroGruposItens.cfm','_self')}" class="form" style="display:inline-block;background:#c5d4ea">										
                                            
                                            <option selected="selected" value=""></option>
                                            <cfoutput query="rsAnoFiltro">
                                                <option  <cfif "#Itn_Ano#" eq "#form.selAltItemAno#">selected</cfif> value="#Itn_Ano#">#Itn_Ano#</option>
                                            </cfoutput>
                                        </select>		
                            </div>        
                                    
                            <div style="margin-right:20px;margin-bottom:10px;float:left;">
                                <label  for="selAltItemGrupo" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                GRUPO:</label>
                                <div ></div>	
                                        <select name="selAltItemGrupo" id="selAltItemGrupo"  onchange="if(this.value!=''){aguarde(); setTimeout('javascript:formAltItem.submit();',2000)}else{window.open('cadastroGruposItens.cfm','_self')}" class="form" style="display:inline-block;width:290px;background:#c5d4ea">										
                                        
                                            <option selected="selected" value=""></option>
                                            <cfif isDefined("form.selAltItemAno") and '#form.selAltItemAno#' neq ''>  
                                                <cfoutput query="rsGrupoFiltro">
                                                    <option  <cfif "#Grp_Codigo#" eq "#form.selAltItemGrupo#">selected</cfif> value="#Grp_Codigo#">#Grp_Codigo# - #Grp_Descricao#</option>
                                                </cfoutput>
                                            </cfif>
                                        </select>              		
                            </div> 

                            <div style="margin-right:20px;margin-bottom:10px;float:left;">
                                <label  for="selAltItem" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                ITEM:</label>
                                <div ></div>	
                                <select name="selAltItem" id="selAltItem"  onchange="if(this.value!=''){aguarde(); setTimeout('javascript:formAltItem.submit();',2000)}else{window.open('cadastroGruposItens.cfm','_self')}" class="form" style="display:inline-block;width:290px;background:#c5d4ea">										
                                    <option selected="selected" value=""></option>
                                    <cfif isDefined("form.selAltItemGrupo") and '#form.selAltItemGrupo#' neq ''>  
                                        <cfoutput query="rsItemFiltro">
                                            <option  <cfif "#Itn_NumItem#" eq "#form.selAltItem#">selected</cfif> value="#Itn_NumItem#">#Itn_NumItem# - #Itn_Descricao#</option>
                                        </cfoutput>
                                    </cfif>
                                </select>              		
                            </div> 
                            <div style="margin-bottom:10px;float:left;">
                                <label  for="selAltModalidade" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                MODALIDADE:</label>
                                <br>	
                                <select name="selAltModalidade" id="selAltModalidade"  class="form" onChange="aguarde(); setTimeout('javascript:formAltItem.submit();',2000)" style="display:inline-block;background:#c5d4ea">
                                    <option selected="selected" value=""></option>
                                    <cfif isDefined("form.selAltItem") and '#form.selAltItem#' neq ''>
                                        <cfoutput query="rsModFiltro">
                                            <option <cfif '#form.selAltModalidade#' eq  '#TUI_Modalidade#' >selected</cfif> value="#TUI_Modalidade#"><cfif "#TUI_Modalidade#" eq 0>PRESENCIAL<cfelseif "#TUI_Modalidade#" eq 1>A DISTÂNCIA<cfelse></cfif></option>
                                        </cfoutput>    
                                    </cfif>
                                </select>
						    </div>

                           
                        </div> 
                    </div>

                    <cfif isDefined("form.selAltModalidade") and '#form.selAltModalidade#' neq '' and '#rsModFiltro.recordcount#' neq 0> 
                        <div align="right" style="position:relative;top:20px;left:633px;width:200px;padding:10px">
                            <cfif '#rsItemFiltrado.TUI_Ativo#' eq 0>
                                <span  STYLE="background:darkred;color:#fff;padding:5px;border:1px solid #fff">ITEM DESATIVADO</span>
                            <cfelse>
                                <span   STYLE="background:blue;color:#fff;padding:5px;border:1px solid #fff">ITEM ATIVO</span></div>
                            </cfif>
                        </div>
                        <div align="left" style="padding:10px;border:1px solid #fff;width:835px;margin-top:0px">
                        
                            <div align="left">
                                <span class="tituloDivAltItem" >Informações disponíveis para alteração</span>
                            </div> 
                            <div style="margin-bottom:20px;">
                                <label  for="altItemDescricao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                DESCRIÇÃO DO ITEM:</label>	
                                <div ></div>	
                                <textarea  name="altItemDescricao"  id="altItemDescricao" cols="112" rows="2" wrap="VIRTUAL" class="form" 
                                style="background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Descricao#</cfoutput></textarea>		
                            </div>

                            <div style="margin-bottom:10px;float:left;">
                                <label  for="selAltItemValorDec" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">VALOR<br>DECLARADO:</label>
                                <div ></div>	
                                <select name="selCadItemValorDec" id="selCadItemValorDec"  class="form" style="display:inline-block;width:50px;">
                                    <option <cfif '#rsItemFiltrado.Itn_ValorDeclarado#' eq 'N'>selected</cfif> value="N">Não</option>
                                    <option <cfif '#rsItemFiltrado.Itn_ValorDeclarado#' eq 'S'>selected</cfif> value="S">Sim</option>
                                </select>			 										
                            </div>

                            <div style="margin-bottom:10px;margin-left:100px;width:200px;float:left;" title="Impede a visualização e tratamento do item em todas as páginas.">
                                <label  for="selAltVisualizacao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">VISUALIZAÇÃO<br>BLOQUEADA:</label>
                                <div ></div>	
                                <select name="selAltVisualizacao" id="selAltVisualizacao"  class="form" style="display:inline-block;width:50px;">
                                    <option <cfif '#rsItemFiltrado.Itn_TipoUnidade#' eq ''>selected</cfif> value="">Não</option>
                                    <option <cfif '#rsItemFiltrado.Itn_TipoUnidade#' eq '99'>selected</cfif> value="99">Sim</option>
                                </select>			 										
                            </div>

                            <div style="margin-bottom:10px;margin-left:200px;" title="Obriga que o gestor valide este item em caso de avaliação NÃO EXECUTA.">
                                <label  for="selAltValidObrig"  style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">VALIDAÇÃO<br>OBRIGATÓRIA:</label>
                                <div ></div>	
                                <select name="selAltValidObrig" id="selAltValidObrig"  class="form" style="display:inline-block;width:50px;">
                                    <option <cfif '#rsItemFiltrado.Itn_ValidacaoObrigatoria#' eq '0'>selected</cfif> value="0">Não</option>
                                    <option <cfif '#rsItemFiltrado.Itn_ValidacaoObrigatoria#' eq '1'>selected</cfif> value="1">Sim</option>
                                </select>			 										
                            </div>

                            <div align="left" style="margin-bottom:30px;">
                                <label  for="altItemOrientacao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS:</label>	 
                                <div ></div>
                                <textarea  name="altItemOrientacao" id="altItemOrientacao" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Orientacao#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;float:left;margin-right:7px">
                                <label  for="altItemAmostra" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">AMOSTRA:</label>	 
                                <div ></div>
                                <textarea  name="altItemAmostra" id="altItemAmostra" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Amostra#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;">
                                <label  for="altItemNorma" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">NORMA:</label>	 
                                <div ></div>
                                <textarea  name="altItemNorma" id="altItemNorma" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_Norma#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;">
                                <label  for="altItemPreRelato" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">RELATO MODELO:</label>	 
                                <div ></div>
                                <textarea  name="altItemPreRelato" id="altItemPreRelato" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_PreRelato#</cfoutput></textarea>		
                            </div>

                            <div align="left" style="margin-bottom:30px;">
                                <label  for="altItemOrientacaoRelato" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">ORIENTAÇÕES:</label>	 
                                <div ></div>
                                <textarea  name="altItemOrientacaoRelato" id="altItemOrientacaoRelato" 
                                style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_OrientacaoRelato#</cfoutput></textarea>		
                            </div>


                            <div id="avisoAlteracao" align="left" style="visibility:hidden;display:none;z-index:1000;background-color:#003390;position:absolute;padding:10px;border:3px solid lightGray;width:620px;">
                                <div align="left" style="padding:3px">   
                                    <span class="tituloDivAltItem" style="font-size:12px;border:2px solid lightGray;align:center;top: -24px;background-color:#003390;">
                                    <img src="figuras/calculadora.png" width="20"  border="0" style="position:relative;top:2px" ></img>                                   
                                    Descrição da Alteração:</span>
                                </div>
                                <div style="border:1px solid transparent;font-size:12px">
                                    <textarea  name="altItemAvisoAlteracao" id="altItemAvisoAlteracao" 
                                    style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"><cfoutput>#rsItemFiltrado.Itn_AvisoAlteracao#</cfoutput></textarea>		
                                </div>
                            </div>

                            <div align="left" style="padding:10px;border:1px solid #fff;width:813px;margin-bottom:30px;">
                                <div align="left">
                                        <span class="tituloDivAltItem" style="font-size:12px">Plano de Teste</span>
                                </div>
                                <div style="margin-bottom:30px;" >
                                    <label  for="selAltItemTipoUnidade"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                    TIPO DE UNIDADE: <span style="color:yellow">(tipos de unidade que tem este item em seu PLANO DE TESTE)</span></label> 
                                    <div ></div>
                                        <cfoutput query="qTipoUnidades">
                                            <div style="float:left;margin-right:15px;border:1px solid transparent;font-size:12px">
                                                <input type="checkbox"  name="selAltItemTipoUnidade" 
                                                <cfif listFind(tipos,'#TUN_Codigo#') neq 0>checked</cfif>
                                                value="#TUN_Codigo#"  onclick="mudaCorCheckedTipo(this);temAGF()"><a style="color:##fff;padding:1px;">#TUN_Descricao#</a></input>  
                                            </div>
                                        </cfoutput>
                                </div>

                                <div style="margin-bottom:30px;border-bottom:1px solid #fff;padding-bottom:20px">
                                    <label  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:8px;">
                                    Legenda:</label>                   	
                                    <a  style="background:green;font-size:8px;padding:2px;border:1px solid #fff">CADASTRADO</a>
                                    <a  style="background:blue;font-size:8px;padding:2px;border:1px solid #fff">SERÁ INCLUÍDO</a>
                                    <a  style="background:red;font-size:8px;padding:2px;border:1px solid #fff">SERÁ EXCLUÍDO</a>
                                </div>  

                                <cfquery dbtype="query" name="rsItemFiltradoOutros">
                                    SELECT DISTINCT TUI_Pontuacao FROM rsItemFiltrado WHERE TUI_TipoUnid<>12
                                </cfquery>

                                <cfquery dbtype="query" name="rsItemFiltradoAGF">
                                        SELECT DISTINCT TUI_Pontuacao FROM rsItemFiltrado WHERE TUI_TipoUnid=12
                                </cfquery>

                                <div></div>
                                <div style="text-align:center;">
                                    <div align="left" style="float:left;margin-right:20px;">
                                        <button id="btCalculadoraAlt" onClick="mostraAvisoAlteracao();mostraCalculadora();PosicaoElemento(this,'calculadoraPontuacaoAlt');" onmouseOver="this.style.backgroundColor='cornflowerBlue';" onMouseOut="this.style.backgroundColor='blue';"
                                        class="botaoCad" style="background-color:blue;color:#fff;font-size:10px;width:66px;padding:2px;">
                                        <span><img src="figuras/calculadora.png" width="30"  border="0"  ></img></span><div></div>Calculadora<br>Pontuação</button>                     
                                    </div>

                                    <div id="selAltItemPontuacaoDiv" align="left" style="float:left;margin-right:20px;visibility:hidden;">
                                        <label  for="selAltItemPontuacao"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                        PONTUAÇÃO:</label> 
                                        <div></div>
                                        <input type="text" id="selAltItemPontuacao" name="selAltItemPontuacao" size="3" onkeypress='return SomenteNumero(event)' style="position:relative;top:2px;text-align:center" 
                                        value="<cfoutput>#rsItemFiltradoOutros.TUI_Pontuacao#</cfoutput>"></input> 
                                    </div>
                                
                                    <div id="selAltItemPontuacaoAGFdiv" align="left" style="visibility:hidden;">
                                        <label  for="selAltItemPontuacaoAGF"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                        PONTUAÇÃO AGF:</label> 
                                        <div></div>
                                        <input type="text" id="selAltItemPontuacaoAGF" name="selAltItemPontuacaoAGF" size="3" onkeypress='return SomenteNumero(event)' style="position:relative;top:2px;text-align:center" 
                                        value="<cfoutput>#rsItemFiltradoAGF.TUI_Pontuacao#</cfoutput>"></input>
                                    </div>   
                                </div> 


                            </div>


                           

                               

                        </div> 

                        <div align="center" style="margin-top:30px;">
                                <a type="button" onClick="return valida_formAltItem()" href="#" class="botaoCad" style="background:blue;color:#fff;font-size:12px;">
                                    Alterar</a> 
                                <a type="button" onClick="return valida_formExcItem()" href="#" class="botaoCad" style="margin-left:150px;background:red;color:#fff;font-size:12px;">
                                    Excluir este Item</a> 
                                <a type="button" onClick="javascript:if(confirm('Deseja cancelar as alterações realizadas?\n\nObs.: Esta ação não cancela as alterações já confirmadas.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="botaoCad" style="margin-left:150px;background:red;color:#fff;font-size:12px;">
                                    Cancelar</a>
                        </div>   
                    </cfif>
               
                    <!---Calculadora de Pontuação--->
                    <div id="calculadoraPontuacaoAlt" align="left" style="visibility:hidden;display:none;z-index:1000;background-color:#003390;position:absolute;padding:10px;border:3px solid lightGray;width:620px;">
                        <div align="left" style="padding:3px">   
                            <span class="tituloDivAltItem" style="font-size:12px;border:2px solid lightGray;align:center;top: -24px;background-color:#003390;">
                            <img src="figuras/calculadora.png" width="20"  border="0" style="position:relative;top:2px" ></img>                                   
                            Calculadora de Pontuação</span>
                        </div>

                        <div style="border:1px solid transparent;font-size:12px">
							<cfoutput query="rsPta">
								<cfif rsPta.PTC_Franquia is 'N'>
									 <input type="checkbox"  name="checkPontuacaoCad" value="#rsPta.PTC_Valor#" onClick="calcularPontuacao();selecptos('#rsPta.PTC_Seq#')">#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input>
									 <div></div> 
								 </cfif>
							</cfoutput>  	
<!---                             <input type="checkbox"  name="checkPontuacao" value="9" onclick="calcularPontuacao();">TEM IMPACTO FINANCEIRO DIRETO = <strong>9 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="4" onclick="calcularPontuacao();">PODE ENSEJAR INDENIZAÇÃO/PENALIZAÇÃO À ECT/MULTAS CONTRATUAIS OU LEGAIS = <strong>4 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="2" onclick="calcularPontuacao();">DESCUMPRIMENTO DE LEI/NORMA EXTERNA = <strong>2 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="1" onclick="calcularPontuacao();">DESCUMPRIMENTO DE NORMA INTERNA = <strong>1 ponto</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="3" onclick="calcularPontuacao();">RISCO À SEGURANÇA E INTEGRIDADE DO PATRIMÔNIO, BENS, OBJETOS E PESSOAS = <strong>3 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacao" value="2" onclick="calcularPontuacao();">RISCO À IMAGEM DA ECT = <strong>2 pontos</strong></input> --->
                            
 							<div id="checkPontuacaoCadAGFdiv" style="margin-top:10px;visiblity:hidden;display:none"> 
                                Pontuação Adicional p/ AGF:<div></div> 
								<input  type="radio" name="checkPontuacaoCadAGF" value="0" onClick="calcularPontuacao('0')" checked>Pontuação Inicial</input>								
								<div></div>
						        <cfoutput query="rsPta">
								   <cfif rsPta.PTC_Franquia is 'S'>
										 <input  type="radio" name="checkPontuacaoCadAGF" value="#rsPta.PTC_Valor#" onClick="calcularPontuacao('#rsPta.PTC_Valor#');selecptosAGF('#rsPta.PTC_Seq#')">#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input> 
									 <div></div> 
								   </cfif>
							      </cfoutput> 
                 <!---           <select id="checkPontuacaoAGF" name="checkPontuacaoAGF" onchange="calcularPontuacao();">
                                    <option value=""  selected></option> 
                                    <option value="1" title="#rsPta.PTC_Valor#">PONTUAÇÃO PREVISTA NO CFP IGUAL A 0(ZERO) = <strong>1 ponto</strong></option>
                                    <option value="3">PONTUAÇÃO PREVISTA NO CFP ENTRE 1 E 10 = <strong>3 pontos</strong></option>
                                    <option value="6">PONTUAÇÃO PREVISTA NO CFP ENTRE 11 E 49 = <strong>6 pontos</strong></option>
                                    <option value="9" >PONTUAÇÃO PREVISTA NO CFP MAIOR OU IGUAL A 50 = <strong>9 pontos</strong></option>
                                </select> --->  
                               
                            </div> 
            
                            <div id="totalDiv" style="visibility:hidden;margin-right:20px;margin-top:20px;float:left">
                                <span style="position:relative;top:-8px">Total: </span><strong><input type="text"  
                                id="pontuacaoCalculada" readonly  size="3"
                                style="font-size:26px;text-align:center;background:transparent;color:white;"></strong></input>
                            </div>

                            <div id="totalAGFdiv" style="visibility:hidden;margin-right:20px;margin-top:20px;float:left;visiblity:hidden;">
                                    <span style="position:relative;top:-8px">Total AGF: </span><strong><input type="text"  id="pontuacaoCalculadaAGF" readonly  size="3"
                                    style="font-size:26px;text-align:center;background:transparent;color:white;"></strong></input>
                            </div>
 
                            <div align="right" style="margin-top:20px;float:left">
                                <button onClick="inserePontuacao()" onmouseOver="this.style.backgroundColor='cornflowerBlue';" onMouseOut="this.style.backgroundColor='blue';"
                                class="botaoCad" style="background:blue;color:#fff;font-size:12px;width:121px">Inserir Pontuação</button> 
                            </div>
                            <div align="right" style="margin-top:20px;">
                                <button onClick="fechaCalculadora()" onmouseOver="this.style.backgroundColor='red';" onMouseOut="this.style.backgroundColor='darkred';"
                                class="botaoCad" style="background:darkred;color:#fff;font-size:12px;width:65px">Fechar</button> 
                            </div>
                        </div>
                    </div>
                    <!---Fim Calculadora de Pontuação--->
            </form>


        </div>
    <style>
        .cke_top{
            <!---background:#003366; --->
        }
        
    </style>

    <script>

        CKEDITOR.replace('altItemOrientacao', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy','-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
                [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                '/',
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]
        });

        CKEDITOR.replace('altItemPreRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy','-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
                [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                '/',
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]
        });

        CKEDITOR.replace('altItemOrientacaoRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy','-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
                [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                '/',
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]
        });

        CKEDITOR.replace('altItemAmostra', {
            width: '400',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [	
                [ 'Preview', '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','RemoveFormat','-','NumberedList', 'BulletedList','SpecialChar','-',
                'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','TextColor','Maximize', 'Table' ]
            ]				
        });

        CKEDITOR.replace('altItemNorma', {
            width: '400',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [	
                [ 'Preview', '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','RemoveFormat','-','NumberedList', 'BulletedList','SpecialChar','-',
                'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','TextColor','Maximize', 'Table' ]
            ]		
        });

        CKEDITOR.replace('altItemAvisoAlteracao', {
            width: '400',
            height: 50,
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [	
                [ 'Preview', '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','RemoveFormat','-','NumberedList', 'BulletedList','SpecialChar','-',
                'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','TextColor','Maximize', 'Table' ]
            ]		
        });


    </script>
           
    </body>
   
</html>