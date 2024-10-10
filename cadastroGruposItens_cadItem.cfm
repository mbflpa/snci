<cfprocessingdirective pageEncoding ="utf-8">  
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="permissao_negada.htm">
	<cfabort>
</cfif>  

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido,Usu_Coordena from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfif isDefined("form.formCadItem") >
    <cfparam name="form.acao" default="#form.acao#">
    <cfparam name="form.selCadItemAno" default="#form.selCadItemAno#">
    <cfparam name="form.tipos" default="#form.tipos#">
    <cfparam name="form.cadfrmptos" default="#form.cadfrmptos#">
	<cfparam name="form.cadfrmptosAGF" default="#form.cadfrmptosAGF#">	
<cfelse>
    <cfparam name="form.acao" default="">
    <cfparam name="form.selCadItemAno" default="">
    <cfparam name="form.tipos" default="">
	<cfparam name="form.cadfrmptos" default="">
	<cfparam name="form.cadfrmptosAGF" default="">	
</cfif>
<cfquery name="rsPta" datasource="#dsn_inspecao#">
	SELECT PTC_Seq, PTC_Valor, PTC_Descricao, PTC_Status, PTC_dtultatu, PTC_Username, PTC_Franquia FROM Pontuacao WHERE PTC_Ano = '#form.selCadItemAno#'
</cfquery>

<cfif isDefined("form.selCadItemAno") and '#form.selCadItemAno#' neq ''>
	<cfif rsPta.recordcount lte 0>
	   <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela PONTUACAO para o ano: #form.selCadItemAno#">
	</cfif>
	<!---  --->
    <cfquery datasource="#dsn_inspecao#" name="rsGrupo">
        SELECT * FROM Grupos_Verificacao WHERE Grp_Ano = '#form.selCadItemAno#'
    </cfquery>
    <cfif '#rsGrupo.recordcount#' eq 0>
       <script>
       <cfoutput>
         alert('Não existem Grupos cadastrados para o ano ' + '#form.selCadItemAno#' + '.');
       </cfoutput>
       </script>
    </cfif>
</cfif>

<cfquery name="qTipoUnidades" datasource="#dsn_inspecao#">
    SELECT * FROM Tipo_Unidades
	ORDER BY TUN_Descricao
</cfquery>


<cfif isDefined("form.acao") and "#form.acao#" eq 'cadItem'>
    <cfquery datasource="#dsn_inspecao#" name="rsItemExiste">
        SELECT Itn_Descricao FROM Itens_Verificacao 
        WHERE Itn_Descricao = '#form.cadItemDescricao#' AND Itn_Ano = #form.selCadItemAno# 
        AND Itn_NumGrupo = '#form.selCadItemGrupo#'
    </cfquery>


    <cfif '#rsItemExiste.recordcount#' eq 0>
         <!---Retorna o maior código de item cadastrado para o grupo selecionado e adiciona 1 para gerar o código do item a ser cadastrado ---> 
        <cfquery datasource="#dsn_inspecao#" name="rsNumItem">
            SELECT MAX(Itn_NumItem) + 1 as numItem FROM Itens_Verificacao
            WHERE Itn_Ano = #form.selCadItemAno# AND Itn_NumGrupo = '#form.selCadItemGrupo#'
        </cfquery>
        <cfset numItem = 1>
        <cfif '#rsNumItem.numItem#' neq ''>
            <cfset numItem = '#rsNumItem.numItem#'>  
        </cfif> 
  <cfloop list="#form.tipos#" index="i">       
  		 <cfset tipo = "#i#"> 
		 <!--- Ajustes para os campos: Itn_Pontuacao, Itn_Classificacao e Itn_PTC_Seq --->
		 <!--- obter os valores para compor o campo: Itn_PTC_Seq --->
		 <cfif tipo neq 12>
			<cfset  auxini = 1>
			<cfset  auxfim = len(trim(#form.cadfrmptos#))>
			<cfloop condition="auxini lt auxfim">
				<cfif auxini is 1>
				<cfset TUIPontuacaoDesc =  mid(form.cadfrmptos,auxini,2)>
				<cfelse>
				<cfset TUIPontuacaoDesc = TUIPontuacaoDesc & ',' & mid(form.cadfrmptos,auxini,2)>
				</cfif>
				<cfset  auxini = auxini + 2>
			</cfloop>
			<cfset auxptodesc = TUIPontuacaoDesc>
			<cfif right(auxptodesc,1)  eq ','>
				<cfset auxptodesc = left(auxptodesc,len(auxptodesc) -1)>
			</cfif>
			<cfset auxpontua = form.selCadItemPontuacao>
		 <cfelse>
				<cfset  auxini = 1>
				<cfset  auxfim = len(trim(#form.cadfrmptos#))>
				<cfloop condition="auxini lt auxfim">
				   <cfif auxini is 1>
					 <cfset TUIPontuacaoDescAGF =  mid(form.cadfrmptos,auxini,2)>
				   <cfelse>
					 <cfset TUIPontuacaoDescAGF = TUIPontuacaoDescAGF & ',' & mid(form.cadfrmptos,auxini,2)>
				   </cfif>
				 <cfset  auxini = auxini + 2>
				</cfloop>					
				<!--- fim TUIPontuacaoDesc  --->
				<cfset auxptodescAGF = TUIPontuacaoDescAGF & ',' & form.cadfrmptosAGF>	
				<cfif right(auxptodescAGF,1)  eq ','>
				  <cfset auxptodescAGF = left(auxptodescAGF,len(auxptodescAGF) -1)>
				</cfif>					
				<cfset auxpontua = form.selCadItemPontuacaoAGF>	
		  </cfif>
		<!--- Obter a Pontuação max pelo ano e tipo da unidade --->
		<cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
			SELECT TUP_PontuacaoMaxima 
			FROM Tipo_Unidade_Pontuacao 
			WHERE TUP_Ano = '#form.selCadItemAno#' AND TUP_Tun_Codigo in (#tipo#)
		</cfquery>
		<cfif rsPtoMax.recordcount lte 0>
		 <cflocation url="SNCI_MENSAGEM.cfm?form.motivo=BASE CADASTRAL: Falta informar os dados na tabela TIPO_UNIDADE_PONTUACAO para o ano: #form.selCadItemAno# e Cod_Tipo_Unidade = #tipo#">
		</cfif>

		<!--- calcular o perc de classificacao do item --->	
		<cfset PercClassifItem = NumberFormat(((auxpontua / rsPtoMax.TUP_PontuacaoMaxima) * 100),999)>	
		<!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
		<cfif PercClassifItem gt 40>
			<cfset ClassifITEM = 'GRAVE'> 
		<cfelseif PercClassifItem gt 10 and PercClassifItem lte 40>
			<cfset ClassifITEM = 'MEDIANO'> 
		<cfelseif PercClassifItem lte 10>
			<cfset ClassifITEM = 'LEVE'> 
		</cfif>	
<!--- Fim Ajustes para os campos: Itn_Pontuacao, Itn_Classificacao e Itn_PTC_Seq --->
                <cfif '#form.selModalidade#' eq 'todas'>
                    <cfquery datasource="#dsn_inspecao#">
                        INSERT INTO TipoUnidade_ItemVerificacao (TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ano,TUI_Ativo)
                        VALUES('0',#tipo#,#form.selCadItemGrupo#,#numItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',#form.selCadItemAno#,0) 
                    </cfquery>
                    <cfquery datasource="#dsn_inspecao#">
                        INSERT INTO TipoUnidade_ItemVerificacao (TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ano,TUI_Ativo)
                        VALUES('1',#tipo#,#form.selCadItemGrupo#,#numItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',#form.selCadItemAno#,0) 
                    </cfquery>
					<cfquery datasource="#dsn_inspecao#">
                        INSERT INTO Itens_Verificacao(Itn_Modalidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_TipoUnidade,Itn_Ano,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Manchete)
                        VALUES('0',#form.selCadItemGrupo#, #numItem#, '#form.cadItemDescricao#','#form.cadItemOrientacao#'
                                , 'D', CONVERT(DATETIME, getdate(), 103), '#qAcesso.Usu_Matricula#', '#form.selCadItemValorDec#', #tipo#, #form.selCadItemAno#
                                ,'#form.cadItemAmostra#','#form.cadItemNorma#','#form.selCadItemValidObrig#','#form.cadItemPreRelato#','#form.cadItemOrientacaoRelato#','#form.cadItemManchete#')                                    
                        </cfquery>
					<cfquery datasource="#dsn_inspecao#">
						INSERT INTO Itens_Verificacao(Itn_Modalidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_TipoUnidade,Itn_Ano,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Manchete)
						VALUES('1',#form.selCadItemGrupo#, #numItem#, '#form.cadItemDescricao#','#form.cadItemOrientacao#'
								, 'D', CONVERT(DATETIME, getdate(), 103), '#qAcesso.Usu_Matricula#', '#form.selCadItemValorDec#', #tipo#, #form.selCadItemAno#
								,'#form.cadItemAmostra#','#form.cadItemNorma#','#form.selCadItemValidObrig#','#form.cadItemPreRelato#','#form.cadItemOrientacaoRelato#','#form.cadItemManchete#')
					</cfquery>	
					<!---  --->	
					<cfif tipo neq 12>
						<cfquery datasource="#dsn_inspecao#">
							UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selCadItemPontuacao#, TUI_Pontuacao_Seq = '#auxptodesc#', TUI_Classificacao = '#ClassifITEM#'
							WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selCadItemAno#' AND TUI_GrupoItem = #form.selCadItemGrupo# AND TUI_ItemVerif = #numItem# and TUI_Modalidade in(0,1)
						</cfquery>
						<cfquery datasource="#dsn_inspecao#">
						UPDATE Itens_Verificacao SET Itn_Pontuacao = #form.selCadItemPontuacao#, Itn_PTC_Seq = '#auxptodesc#', Itn_Classificacao = '#ClassifITEM#'
						WHERE Itn_Modalidade In (0,1) AND Itn_Ano = '#form.selCadItemAno#' AND Itn_TipoUnidade = #tipo# AND Itn_NumGrupo = #form.selCadItemGrupo# AND Itn_NumItem = #numItem# 
						</cfquery>

					<cfelse>
						<cfquery datasource="#dsn_inspecao#">
							UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selCadItemPontuacaoAGF#, TUI_Pontuacao_Seq = '#auxptodescAGF#', TUI_Classificacao = #ClassifITEM#'
							WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selCadItemAno#' AND TUI_GrupoItem = '#form.selCadItemGrupo#' AND TUI_ItemVerif = #numItem# and TUI_Modalidade in(0,1)
						</cfquery>
						<cfquery datasource="#dsn_inspecao#">
						UPDATE Itens_Verificacao SET Itn_Pontuacao = #form.selCadItemPontuacaoAGF#, Itn_PTC_Seq = '#auxptodescAGF#', Itn_Classificacao = '#ClassifITEM#'
						WHERE Itn_Modalidade In (0,1) AND Itn_Ano = '#form.selCadItemAno#' AND Itn_TipoUnidade = #tipo# AND Itn_NumGrupo = #form.selCadItemGrupo# AND Itn_NumItem = #numItem# 
						</cfquery>						
					</cfif>					
					<!---  --->
                <cfelse>
                    <cfquery datasource="#dsn_inspecao#">
                        INSERT INTO TipoUnidade_ItemVerificacao (TUI_Modalidade,TUI_TipoUnid,TUI_GrupoItem,TUI_ItemVerif,TUI_DtUltAtu,TUI_UserName,TUI_Ano,TUI_Ativo)
                        VALUES('#form.selModalidade#',#tipo#,#form.selCadItemGrupo#,#numItem#,CONVERT(DATETIME, getdate(), 103),'#qAcesso.Usu_Matricula#',#form.selCadItemAno#,0) 
                    </cfquery>
					<cfquery datasource="#dsn_inspecao#">
						INSERT INTO Itens_Verificacao(Itn_Modalidade,Itn_NumGrupo,Itn_NumItem,Itn_Descricao,Itn_Orientacao,Itn_Situacao,Itn_DtUltAtu,Itn_UserName,Itn_ValorDeclarado,Itn_TipoUnidade,Itn_Ano,Itn_Amostra,Itn_Norma,Itn_ValidacaoObrigatoria,Itn_PreRelato,Itn_OrientacaoRelato,Itn_Manchete)
							VALUES('#form.selModalidade#',#form.selCadItemGrupo#, #numItem#, '#form.cadItemDescricao#','#form.cadItemOrientacao#'
										, 'D', CONVERT(DATETIME, getdate(), 103), '#qAcesso.Usu_Matricula#', '#form.selCadItemValorDec#', #tipo#, #form.selCadItemAno#
										,'#form.cadItemAmostra#','#form.cadItemNorma#','#form.selCadItemValidObrig#','#form.cadItemPreRelato#','#form.cadItemOrientacaoRelato#','#form.cadItemManchete#')                    
                    </cfquery>		
					<!---  --->	
					<cfif tipo neq 12>
						<cfquery datasource="#dsn_inspecao#">
							UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selCadItemPontuacao#, TUI_Pontuacao_Seq = '#auxptodesc#', TUI_Classificacao = '#ClassifITEM#'
							WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selCadItemAno#' AND TUI_GrupoItem = #form.selCadItemGrupo# AND TUI_ItemVerif = #numItem# and TUI_Modalidade = '#form.selModalidade#'
						</cfquery>
						<cfquery datasource="#dsn_inspecao#">
						UPDATE Itens_Verificacao SET Itn_Pontuacao = #form.selCadItemPontuacao#, Itn_PTC_Seq = '#auxptodesc#', Itn_Classificacao = '#ClassifITEM#'
						WHERE Itn_Modalidade = '#form.selModalidade#' AND Itn_Ano = '#form.selCadItemAno#' AND Itn_TipoUnidade = #tipo# AND Itn_NumGrupo = #form.selCadItemGrupo# AND Itn_NumItem = #numItem# 
						</cfquery>

					<cfelse>
						<cfquery datasource="#dsn_inspecao#">
							UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selCadItemPontuacaoAGF#, TUI_Pontuacao_Seq = '#auxptodescAGF#', TUI_Classificacao = '#ClassifITEM#'
							WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selCadItemAno#' AND TUI_GrupoItem = '#form.selCadItemGrupo#' AND TUI_ItemVerif = #numItem# and TUI_Modalidade = '#form.selModalidade#'
						</cfquery>
						<cfquery datasource="#dsn_inspecao#">
						UPDATE Itens_Verificacao SET Itn_Pontuacao = #form.selCadItemPontuacaoAGF#, Itn_PTC_Seq = '#auxptodescAGF#', Itn_Classificacao = '#ClassifITEM#'
						WHERE Itn_Modalidade = '#form.selModalidade#' AND Itn_Ano = '#form.selCadItemAno#' AND Itn_TipoUnidade = #tipo# AND Itn_NumGrupo = #form.selCadItemGrupo# AND Itn_NumItem = #numItem# 
						</cfquery>						
					</cfif>					
					<!---  --->			
                </cfif>
<!---  				    <script>
				   <cfoutput>
					 alert('cadfrmptos : ' + '#form.cadfrmptos#' + '  cadfrmptosAGF : ' + '#form.cadfrmptosAGF#');
				   </cfoutput>
				   </script>  --->
<!---                 <cfif tipo neq 12>
                    <cfquery datasource="#dsn_inspecao#">
                        UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selCadItemPontuacao#, TUI_Pontuacao_Seq = '#auxptodesc#', TUI_Classificacao = #ClassifITEM#'
                        WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selCadItemAno#' AND TUI_GrupoItem = '#form.selCadItemGrupo#' AND TUI_ItemVerif = #numItem#
                    </cfquery>
                <cfelse>
		
                    <cfquery datasource="#dsn_inspecao#">
                        UPDATE TipoUnidade_ItemVerificacao SET TUI_Pontuacao = #form.selCadItemPontuacaoAGF#, TUI_Pontuacao_Seq = '#auxptodescAGF#', TUI_Classificacao = #ClassifITEM#'
                        WHERE TUI_TipoUnid = #tipo# AND TUI_Ano = '#form.selCadItemAno#' AND TUI_GrupoItem = '#form.selCadItemGrupo#' AND TUI_ItemVerif = #numItem#
                    </cfquery>
                </cfif> --->
        </cfloop>

        <script>
            var numItem = <cfoutput>#form.selCadItemGrupo#.#numItem#</cfoutput>;
            alert('Item cadastrado com sucesso!\n\nNº do Item gerado automaticamente: ' + numItem + '\n\nSituação: DESATIVADO');
            window.open('cadastroGruposItens.cfm','_self');
        </script>

    <cfelse>
      <script>
        alert('Já existe um item cadastrado com a mesma Descrição e Ano.\n\nEsta ação foi cancelada.');
      </script>
    </cfif> 

   
   
</cfif>

<html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <title>SNCI - CADASTRO DE GRUPOS E ITENS</title>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">


    <style type="text/css">    
        .tituloDivCadGrupo{
            padding:5px;
            position:relative;
            top: -29px;
            background: #003366;
            border: 1px solid #fff;
        }
    </style>

    <script type="text/javascript">  


        function mudaCorCheckedCad(b){
            (b.checked==true) ? b.parentNode.style.background='blue' : b.parentNode.style.background='none';
            (b.checked==true) ? b.parentNode.style.border='1px solid #fff' : b.parentNode.style.border='1px solid transparent';
        }
        if(document.forms['formCadItem']){
            var all = document.forms['formCadItem'].elements;
            for(x=0;x<all.length;x++){
            mudaCorCheckedCad(all[x]);
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
     
        var tiposSelecionados="";
   

        function valida_formCadItem(){
            tiposSelecionados = selectChecbox('selCadItemTipoUnidade');

            var frm = document.getElementById('formCadItem');

            if (frm.selCadItemAno.value == '') {
				alert('Informe o ano que este item será utilizado!');
				frm.selCadItemAno.focus();
				return false;
			}

            if (frm.selCadItemGrupo.value == '') {
				alert('Informe um grupo para item!');
				frm.selCadItemGrupo.focus();
				return false;
			}

            if (frm.selCadItemValorDec.value == '') {
				alert('Informe se o item prevê ou não valor declarado!');
				frm.selCadItemValorDec.focus();
				return false;
			}
            
            if (frm.selCadItemValidObrig.value == '') {
				alert('Informe se o item deve obrigatoriamente ser validado pelo gestor em caso de avaliação "NÃO EXECUTA"!');
				frm.selCadItemValidObrig.focus();
				return false;
			}

            if (frm.cadItemDescricao.value == '') {
				alert('Informe uma descrição para item!');
				frm.cadItemDescricao.focus();
				return false;
			}

            if (frm.cadItemManchete.value == '') {
				alert('Informar a Manchete para item!');
				frm.cadItemManchete.focus();
				return false;
			}

            if (CKEDITOR.instances.cadItemOrientacao.getData()== '') {
				alert('Informe "COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS" para o item!');
				CKEDITOR.instances.cadItemOrientacao.focus();
				return false;
			}


            if (CKEDITOR.instances.cadItemAmostra.getData()== '') {
				alert('Informe a Amostra para o item!');
				CKEDITOR.instances.cadItemAmostra.focus();
				return false;
			}

            if (CKEDITOR.instances.cadItemNorma.getData()== '') {
				alert('Informe a Norma para o item!');
				CKEDITOR.instances.cadItemNorma.focus();
				return false;
			}

            if (CKEDITOR.instances.cadItemPreRelato.getData()== '') {
				alert('Informe um modelo de relato para o item.');
				CKEDITOR.instances.cadItemPreRelato.focus();
				return false;
			}
            
            if (CKEDITOR.instances.cadItemOrientacaoRelato.getData()== '') {
				alert('Informe uma orientação para o órgão.');
				CKEDITOR.instances.cadItemOrientacaoRelato.focus();
				return false;
			}

            if (frm.selModalidade.value == '') {
				alert('Informe a modalidade do item!');
				frm.selModalidade.focus();
				return false;
			}

            if (tiposSelecionados == '') {
				alert('Selecione, pelo menos, 01(um) tipo de unidade para o qual o item será aplicado nas avaliações!');
				return false;
			}

            if (frm.selCadItemPontuacao.value == '' || frm.selCadItemPontuacao.value == 0) {
				alert('Informe a Pontuação para o item.\n\nObs.: Utilizar a "Calculadora de Pontuação".');
                frm.selCadItemPontuacao.focus();
				return false;
			}  

            if ((frm.selCadItemPontuacaoAGF.value == '' || frm.selCadItemPontuacaoAGF.value == 0) && isVisible(document.getElementById('selCadItemPontuacaoAGF'))==true) {
				alert('Informe a Pontuação do item para AGF.\n\nObs.: Utilizar a "Calculadora de Pontuação".');
                frm.selCadItemPontuacaoAGF.focus();
				return false;
			}


            if(window.confirm('Deseja cadastrar  este Item?')){  
                
                frm.tipos.value=tiposSelecionados; 
                frm.acao.value = 'cadItem';
			    aguarde();
                setTimeout('document.getElementById("formCadItem").submit();',2000);
                return true;	
            }else{
                return false;
            }

        }  
        
        //script para calculadora de Pontuação
        
        // apos load muda cor dos tipos de unidades conforme item selecionado
        
        function temAGFcad(){            
            tiposSelecionados = selectChecbox("selCadItemTipoUnidade"); 
            tiposSelecionadosList = tiposSelecionados.split(',')

            

            if(tiposSelecionados.indexOf("12") != -1 && tiposSelecionadosList.length >=1){
                document.getElementById('checkPontuacaoCadAGFdiv').style.visibility = 'visible';
                document.getElementById('checkPontuacaoCadAGFdiv').style.display = 'block';
                document.getElementById('totalDivCad').style.visibility = 'visible';
                document.getElementById('totalDivCad').style.position = 'relative';
                document.getElementById('totalAGFdivCad').style.visibility = 'visible';
                document.getElementById('selCadItemPontuacaoDiv').style.position = 'relative'; 
                document.getElementById('selCadItemPontuacaoAGFdiv').style.visibility = 'visible'; 
                document.getElementById('selCadItemPontuacaoDiv').style.visibility = 'visible';
                document.getElementById('selCadItemPontuacaoDiv').style.position = 'relative';
                document.getElementById('btCalculadoraDivCad').style.visibility = 'visible';
                document.getElementById('btCalculadoraDivCad').style.display = 'block';
                
            }
            
            if(tiposSelecionados.indexOf("12") != -1 && tiposSelecionadosList.length==1){
                document.getElementById('checkPontuacaoCadAGFdiv').style.visibility = 'visible';
                document.getElementById('checkPontuacaoCadAGFdiv').style.display = 'block';                
                document.getElementById('totalAGFdivCad').style.visibility = 'visible';
                document.getElementById('totalDivCad').style.visibility = 'hidden';
                document.getElementById('totalDivCad').style.position = 'absolute';
                document.getElementById('selCadItemPontuacaoAGFdiv').style.visibility = 'visible'; 
                document.getElementById('selCadItemPontuacaoDiv').style.visibility = 'hidden';
                document.getElementById('selCadItemPontuacaoDiv').style.position = 'absolute';
                document.getElementById('btCalculadoraDivCad').style.visibility = 'visible';
                document.getElementById('btCalculadoraDivCad').style.display = 'block';

            }
            
            if(tiposSelecionados.indexOf("12") == -1){
                document.getElementById('checkPontuacaoCadAGFdiv').style.visibility = 'hidden';
                document.getElementById('checkPontuacaoCadAGFdiv').style.display = 'none';  
                document.getElementById('totalAGFdivCad').style.visibility = 'hidden';
                document.getElementById('totalDivCad').style.visibility = 'visible';
                document.getElementById('totalDivCad').style.position = 'relative';
                document.getElementById('selCadItemPontuacaoAGFdiv').style.visibility = 'hidden';
                document.getElementById('selCadItemPontuacaoDiv').style.visibility = 'visible'; 
                document.getElementById('selCadItemPontuacaoDiv').style.position = 'relative';   
                document.getElementById('btCalculadoraDivCad').style.visibility = 'visible';
                document.getElementById('btCalculadoraDivCad').style.display = 'block';          
            }

            if(tiposSelecionados.length==0){
                document.getElementById('btCalculadoraDivCad').style.visibility = 'hidden';
                document.getElementById('btCalculadoraDivCad').style.display = 'none'; 
                document.getElementById('checkPontuacaoCadAGFdiv').style.visibility = 'hidden';
                document.getElementById('checkPontuacaoCadAGFdiv').style.display = 'none';  
                document.getElementById('totalAGFdivCad').style.visibility = 'hidden';
                document.getElementById('totalDivCad').style.visibility = 'hidden';
                document.getElementById('totalDivCad').style.position = 'absolute';
                document.getElementById('selCadItemPontuacaoAGFdiv').style.visibility = 'hidden';
                document.getElementById('selCadItemPontuacaoDiv').style.visibility = 'hidden'; 
                document.getElementById('selCadItemPontuacaoDiv').style.position = 'absolute';
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
        function calcularPontuacaoCad(){
			document.getElementById("selCadItemPontuacao").value = 0;
			//document.getElementById('selCadItemPontuacaoAGF').value = 0;
            ptTotal = 0   
			ptTotalAGF = 0;      
            var pontosSelecionados = selectChecbox("checkPontuacaoCad");
            pontosSelecionados = pontosSelecionados.split(',');           
		
            for(var i = 0; i < pontosSelecionados.length; i++){
                ptTotal= ptTotal + (1*pontosSelecionados[i]);     
            }                     
            document.getElementById('pontuacaoCalculadaCad').value = ptTotal;  
			
			var pntSelecagf = selectChecbox("checkPontuacaoCadAGF");
            pntSelecagf = pntSelecagf.split(',');           
		
            for(var i = 0; i < pntSelecagf.length; i++){
			   ptTotalAGF= ptTotalAGF + (1*pntSelecagf[i]);     
            } 
            document.getElementById('pontuacaoCalculadaCadAGF').value = ptTotal + (ptTotalAGF); 
			document.getElementById('selCadItemPontuacaoAGF').value = ptTotalAGF;
        }
		
	function inserePontuacaoCad(){
	if (document.getElementById('selCadItemPontuacaoAGF').value == 0 && isVisible(document.getElementById('checkPontuacaoCadAGF'))==true) {
			alert('Selecione a pontuação adicional para a AGF.');
			document.getElementById('checkPontuacaoCadAGF').focus();
			return false;
		}else{  
			document.getElementById('selCadItemPontuacao').value = ptTotal; 
			document.getElementById('selCadItemPontuacaoAGF').value = ptTotal + (document.getElementById('selCadItemPontuacaoAGF').value *1); 
			document.getElementById("calculadoraPontuacaoCad").style.visibility = 'hidden';
			document.getElementById("calculadoraPontuacaoCad").style.display = 'none';
		}
	}		
/*
        var ptTotal=0;        
        function calcularPontuacaoCad(){
            ptTotal = 0         
            var pontosSelecionados = selectChecbox("checkPontuacaoCad");
            pontosSelecionados = pontosSelecionados.split(',');           
            for(var i = 0; i < pontosSelecionados.length; i++){
                ptTotal= ptTotal + (1*pontosSelecionados[i]);     
            }                     
            document.getElementById('pontuacaoCalculadaCad').value = ptTotal;  
            document.getElementById('pontuacaoCalculadaCadAGF').value = ptTotal +(document.getElementById('checkPontuacaoCadAGF').value *1); 
        }

        function inserePontuacaoCad(){
            if (document.getElementById('checkPontuacaoCadAGF').value =="" && isVisible(document.getElementById('checkPontuacaoCadAGF'))==true) {
				alert('Selecione a Pontuação adicional para a AGF.');
                document.getElementById('checkPontuacaoCadAGF').focus();
				return false;
			}else{           
                document.getElementById('selCadItemPontuacao').value = ptTotal; 
                document.getElementById('selCadItemPontuacaoAGF').value = ptTotal + (document.getElementById('checkPontuacaoCadAGF').value *1); 
                document.getElementById("calculadoraPontuacaoCad").style.visibility = 'hidden';
                document.getElementById("calculadoraPontuacaoCad").style.display = 'none';
            }
        }
*/
        function mostraCalculadoraCad(){
            if (isVisible(document.getElementById('calculadoraPontuacaoCad'))==true) {
                document.getElementById("calculadoraPontuacaoCad").style.visibility = 'hidden';
                document.getElementById("calculadoraPontuacaoCad").style.display = 'none';
            }else{
                document.getElementById("calculadoraPontuacaoCad").style.visibility = 'visible';
                document.getElementById("calculadoraPontuacaoCad").style.display = 'block';
                document.getElementById("calculadoraPontuacaoCad").focus();
            }
            
        }

        function fechaCalculadoraCad(){
            document.getElementById("calculadoraPontuacaoCad").style.visibility = 'hidden';
            document.getElementById("calculadoraPontuacaoCad").style.display = 'none';
            
        }
        //Fim script para calculadora de Pontuação

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

function selecptoscad(a){
//	alert('Linha 539 ' + a);
    var frm = document.getElementById('formCadItem');
	var aux = frm.cadfrmptos.value;
    frm.cadfrmptos.value = '';
	if (aux == '') 
	   {
	   aux = a;
	   frm.cadfrmptos.value = aux;
	//   	   alert('linha114 ' + aux);
	   } 
	else 
	   {
	   if (aux == a) 
	   {
	   aux = '';
	   frm.cadfrmptos.value = aux;
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
		 frm.cadfrmptos.value = aux;
	  // 	   alert('linha134 ' + aux);
		} 
		else 
		  {
		   if (posic == 0)
		   {
		    aux = aux.substring(2, tam);
			frm.cadfrmptos.value = aux;
	  //	   alert('linha142 ' + aux);
		   } 
		   else 
		     {
		      if ((posic + 1) == tam) 
			  {
			   aux = aux.substring(0, (posic - 1));
			   frm.cadfrmptos.value = aux;
			//   alert('linha150 ' + aux);
			  } 
			  else 
			      {
				    aux = aux.substring(0, (posic)) + aux.substring((posic + 2), tam);
					frm.cadfrmptos.value = aux;
		   	    //    alert('linha156 ' + aux);
				  }
				 // aux = '';
		     }
		  }
	   }
	 }
	
//	alert(aux);
 //   alert('Linha 594  cadfrmptos: ' + frm.cadfrmptos.value);
}
//=============================
function selecptosAGFcad(a){
//	alert('Linha 601' + a);
    var frm = document.getElementById('formCadItem');
    frm.cadfrmptosAGF.value = a;
//	alert(aux);
//    alert('Linha 605 valor salvo: ' + frm.cadfrmptosAGF.value);
}

    </script>


 
</head>
    <body id="main_body" style="background:#fff;">
   
        <div align="left" >
            <form id="formCadItem" nome="formCadItem" enctype="multipart/form-data" method="post" >
                <input type="hidden" value="" id="acao" name="acao">
                <input type="hidden" value="" id="tipos" name="tipos"> 
				<input type="hidden" value="" id="cadfrmptos" name="cadfrmptos">
				<input type="hidden" value="" id="cadfrmptosAGF" name="cadfrmptosAGF">  
                
                    
                    <div align="left" style="margin-bottom:10px;padding:10px;border:1px solid #fff;">
                            <div align="left">
                                    <span class="tituloDivAltGrupo" >Item</span>
                            </div>   

                            <div style="margin-bottom:10px;float:left;;margin-right:20px;">
                                        <label  for="selCadItemAno" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">ANO:</label>
                                        <br>
                                        <select name="selCadItemAno" id="selCadItemAno" onchange="aguarde(); setTimeout('javascript:formCadItem.submit();',2000)" class="form" onChange="" style="display:inline-block;">										
                                            <cfset anoInic = year(Now())> 							
                                            <cfset anoFinal = anoInic + 1>
                                            <option selected="selected" value=""></option>
                                            <cfoutput>
                                                <option  <cfif "#anoInic#" eq "#form.selCadItemAno#">selected</cfif> value="#anoInic#">#anoInic#</option>
                                                <option  <cfif "#anoFinal#" eq "#form.selCadItemAno#">selected</cfif> value="#anoFinal#">#anoFinal#</option>
                                            </cfoutput>
                                        </select>		
                            </div>        
                                    
                            <div style="margin-right:20px;margin-bottom:10px;float:left;">
                                <label  for="selCadItemGrupo" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                GRUPO:</label>
                                <br>
                                        <select name="selCadItemGrupo" id="selCadItemGrupo"  class="form" onChange="" style="display:inline-block;width:540px;">										
                                        
                                            <option selected="selected" value=""></option>
                                            <cfif isDefined("form.selCadItemAno") and '#form.selCadItemAno#' neq ''>  
                                                <cfoutput query="rsGrupo">
                                                    <option  value="#Grp_Codigo#">#Grp_Codigo# - #Grp_Descricao#</option>
                                                </cfoutput>
                                            </cfif>
                                        </select>              		
                            </div> 

                            <div style="margin-bottom:10px;float:left;position:relative;top:-13px;LEFT:10px" title="Impede a visualização e tratamento do item em todas as páginas.">
                                <label  for="selCadItemValorDec" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                VALOR<br>DECLARADO:</label>
                                <br>
                                <select name="selCadItemValorDec" id="selCadItemValorDec"  class="form" onChange="" style="display:inline-block;">
                                    <option selected="selected" value=""></option>
                                    <option value="N">Não</option>
                                    <option value="S">Sim</option>
                                </select>										
                            </div>

                            <div style="margin-bottom:10px;margin-left:40px;position:relative;top:-13px;left:20px" title="Obriga que o gestor valide este item em caso de avaliação NÃO EXECUTA.">
                                <label  for="selCadItemValidObrig" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                VALIDAÇÃO<br>OBRIGATÓRIA:</label>
                                <br>
                                <select name="selCadItemValidObrig" id="selCadItemValidObrig"  class="form" onChange="" style="display:inline-block;">
                                    <option selected="selected" value=""></option>
                                    <option value="0">Não</option>
                                    <option value="1">Sim</option>
                                </select>										
                            </div>

                            <div style="margin-bottom:10px;">
                                <label  for="cadItemDescricao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                DESCRIÇÃO DO ITEM:</label>	
                                <br>
                                <textarea  name="cadItemDescricao"  id="cadItemDescricao" cols="113" rows="2" wrap="VIRTUAL" class="form" style="background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
                            </div>
                            <div style="margin-bottom:10px;">
                                <label  for="cadItemManchete" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;">
                                MANCHETE:</label>	
                                <br>
                                <textarea  name="cadItemManchete"  id="cadItemManchete" cols="113" rows="2" wrap="VIRTUAL" class="form" style="background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
                            </div>  
                            <div style="margin-bottom:10px;">
                                <label  for="cadItemOrientacao" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS:</label>	
                                <br>
                                <textarea  name="cadItemOrientacao" id="cadItemOrientacao" style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
                            </div>

                            <div style="float:left;margin-bottom:10px;margin-right:15px">
                                <label  for="cadItemAmostra" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">AMOSTRA:</label>	
                                <br>
                                <textarea  name="cadItemAmostra" id="cadItemAmostra" style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
                            </div>

                            <div style="margin-bottom:10px;">
                                <label  for="cadItemNorma" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">NORMA:</label>	
                                <br>
                                <textarea  name="cadItemNorma" id="cadItemNorma" style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
                            </div>

                            <div style="margin-bottom:10px;">
                                <label  for="cadItemPreRelato" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">RELATO MODELO:</label>	
                                <br>
                                <textarea  name="cadItemPreRelato" id="cadItemPreRelato" style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
                            </div>

                            <div style="margin-bottom:10px;">
                                <label  for="cadItemOrientacaoRelato" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">ORIENTAÇÕES UNIDADE/ÓRGÃO:</label>	
                                <br>
                                <textarea  name="cadItemOrientacaoRelato" id="cadItemOrientacaoRelato" style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif"></textarea>		
                            </div>

                            
                    </div>

                    <div align="left" style="margin-top:30px;margin-bottom:10px;padding:10px;border:1px solid #fff;">
                        <div align="left">
								<span class="tituloDivAltGrupo" >Plano de Teste</span>
						</div>
                        <div style="margin-bottom:10px;float:left;margin-right:20px;">
                            <label  for="selModalidade" style="color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                            MODALIDADE:</label>
                            <br>	
                             <select name="selModalidade" id="selModalidade"  class="form" onChange="" style="display:inline-block;">
                                <option selected="selected" value=""></option>
                                    <option value="todas">TODAS</option>
                                    <option value="0">PRESENCIAL</option>
									<option value="1">A DISTÁNCIA</option>
							</select>
						</div>
                       
                        <div style="margin-bottom:30px;width:680px;text-align:justify" >
                            <label  for="selCadItemTipoUnidade"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                            TIPO DE UNIDADE: <span style="color:yellow">(Selecione os tipos de unidade que terão este item em seu PLANO DE TESTE)</span></label>
                            <br>
                            <cfoutput query="qTipoUnidades">
                                <div style="float:left;margin-right:15px;border:1px solid transparent;font-size:12px">
                                    <input type="checkbox"  name="selCadItemTipoUnidade"  
                                    value="#TUN_Codigo#"  onclick="mudaCorCheckedCad(this);temAGFcad();"><a class="labelCheck" style="padding:1px;">#TUN_Descricao#</a></input>  
                                </div>
                            </cfoutput>
                        </div> 
                         <div></div>
                        <div id="btCalculadoraDivCad"  style="text-align:center;visibility:hidden;display:none;">
                            <div align="left" style="float:left;margin-right:20px;">
                                <button id="btCalculadoraCad" onClick="mostraCalculadoraCad();PosicaoElemento(this,'calculadoraPontuacaoCad');" onmouseOver="this.style.backgroundColor='cornflowerBlue';" onMouseOut="this.style.backgroundColor='blue';"
                                class="botaoCad" style="position:relative;top:-22px;background-color:blue;color:#fff;font-size:10px;width:66px;padding:2px;">
                                <span><img src="figuras/calculadora.png" width="30"  border="0"  ></img></span><div></div>Calculadora<br>Pontuação</button>                     
                            </div>

                            <div id="selCadItemPontuacaoDiv" align="left" style="float:left;margin-right:20px;visibility:hidden;">
                                <label  for="selCadItemPontuacao"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                PONTUAÇÃO:</label> 
                                <div></div>
                                <input readonly type="text" id="selCadItemPontuacao" name="selCadItemPontuacao" size="3" onkeypress='return SomenteNumero(event)' style="position:relative;top:2px;text-align:center" 
                                ></input>
                                    
                            </div>
                        
                            <div id="selCadItemPontuacaoAGFdiv" align="left" style="visibility:hidden;">
                                <label  for="selCadItemPontuacaoAGF"  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px">
                                PONTUAÇÃO AGF:</label> 
                                <div></div>
                                <input readonly type="text" id="selCadItemPontuacaoAGF" name="selCadItemPontuacaoAGF" size="3" onkeypress='return SomenteNumero(event)' style="position:relative;top:2px;text-align:center" 
                                ></input>
                                
                            </div>
                        
                            
                        </div>
                    </div> 

                      

                    <div align="center">
						<a type="button" onClick="return valida_formCadItem()" href="#" class="botaoCad" style="background:blue;color:#fff;font-size:12px">Cadastrar</a>     
                         <a type="button" onClick="javascript:if(confirm('Deseja cancelar este cadastro?\n\nObs: Esta ação não cancela cadastros já confirmados.\n\nCaso afirmativo, clique em OK.')){window.open('cadastroGruposItens.cfm','_self')}" href="#" class="botaoCad" style="margin-left:150px;background:red;color:#fff;font-size:12px;">
                                    Cancelar</a>
                    </div> 

                    <!---Calculadora de Pontuação--->
                    
                    <div id="calculadoraPontuacaoCad" align="left" style="visibility:hidden;display:none;z-index:1000;background-color:#003390;position:absolute;padding:10px;border:3px solid lightGray;width:620px;">
                        <div align="left" style="">   
                            <span class="tituloDivCadItem" style="padding:4px;font-size:12px;border:2px solid lightGray;position:relative;top:-24px;background-color:#003390;">
                            <img src="figuras/calculadora.png" width="20"  border="0" style="position:relative;top:2px" ></img>                                   
                            Calculadora de Pontuação</span>
                        </div>

                        <div style="border:1px solid transparent;font-size:12px">
							<cfoutput query="rsPta">
								<cfif rsPta.PTC_Franquia is 'N'>
									 <input type="checkbox" id="checkPontuacaoCad" name="checkPontuacaoCad" value="#rsPta.PTC_Valor#" onClick="calcularPontuacaoCad();selecptoscad('#rsPta.PTC_Seq#')">#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input>
									 <div></div> 
								 </cfif>
							</cfoutput> 
<!---                             <input type="checkbox"  name="checkPontuacaoCad" value="9" onclick="calcularPontuacaoCad();">TEM IMPACTO FINANCEIRO DIRETO = <strong>9 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacaoCad" value="4" onclick="calcularPontuacaoCad();">PODE ENSEJAR INDENIZAÇÃO/PENALIZAÇAO À ECT/MULTAS CONTRATUAIS OU LEGAIS = <strong>4 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacaoCad" value="2" onclick="calcularPontuacaoCad();">DESCUMPRIMENTO DE LEI/NORMA EXTERNA = <strong>2 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacaoCad" value="1" onclick="calcularPontuacaoCad();">DESCUMPRIMENTO DE NORMA INTERNA = <strong>1 ponto</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacaoCad" value="3" onclick="calcularPontuacaoCad();">RISCO À SEGURANÇA E INTEGRIDADE DO PATRIMÔNIO, BENS, OBJETOS E PESSOAS = <strong>3 pontos</strong></input>
                            <div></div>
                            <input type="checkbox"  name="checkPontuacaoCad" value="2" onclick="calcularPontuacaoCad();">RISCO À IMAGEM DA ECT = <strong>2 pontos</strong></input> 
--->
                            
                            <div id="checkPontuacaoCadAGFdiv" style="margin-top:10px;visiblity:hidden;display:none">
                                Pontuação Adicional p/ AGF:<div></div>
								  <input  type="radio" name="checkPontuacaoCadAGF" value="0" onClick="calcularPontuacaoCad('0')" checked>Pontuação Inicial</input>								
								  <div></div>
						          <cfoutput query="rsPta">
								   <cfif rsPta.PTC_Franquia is 'S'>
										 <input  type="radio" name="checkPontuacaoCadAGF" value="#rsPta.PTC_Valor#" onClick="calcularPontuacaoCad('#rsPta.PTC_Valor#');selecptosAGFcad('#rsPta.PTC_Seq#')">#rsPta.PTC_Descricao# = <strong>#rsPta.PTC_Valor# pontos</strong></input> 
									 <div></div> 
								   </cfif>
							      </cfoutput> 
<!---                                 <select id="checkPontuacaoCadAGF" name="checkPontuacaoCadAGF" onchange="calcularPontuacaoCad();">
                                    <option value=""  selected></option> 
                                    <option value="1">PONTUAÇÃO PREVISTA NO CFP IGUAL A 0(ZERO) = <strong>1 ponto</strong></option>
                                    <option value="3">PONTUAÇÃO PREVISTA NO CFP ENTRE 1 E 10 = <strong>3 pontos</strong></option>
                                    <option value="6">PONTUAÇÃO PREVISTA NO CFP ENTRE 11 E 49 = <strong>6 pontos</strong></option>
                                    <option value="9" >PONTUAÇÃO PREVISTA NO CFP MAIOR OU IGUAL A 50 = <strong>9 pontos</strong></option>
                                </select> 
--->
                            </div>
            
                            <div id="totalDivCad" style="visibility:hidden;margin-right:20px;margin-top:20px;float:left">
                                <span style="position:relative;top:-8px">Total: </span><strong><input type="text"  
                                id="pontuacaoCalculadaCad" readonly  size="3"
                                style="font-size:26px;text-align:center;background:transparent;color:white;"></strong></input>
                            </div>

                            <div id="totalAGFdivCad" style="visibility:hidden;margin-right:20px;margin-top:20px;float:left;visiblity:hidden;">
                                    <span style="position:relative;top:-8px">Total AGF: </span><strong><input type="text"  id="pontuacaoCalculadaCadAGF" readonly  size="3"
                                    style="font-size:26px;text-align:center;background:transparent;color:white;"></strong></input>
                            </div>
 
                            <div align="right" style="margin-top:20px;float:left">
                                <button onClick="inserePontuacaoCad()" onmouseOver="this.style.backgroundColor='cornflowerBlue';" onMouseOut="this.style.backgroundColor='blue';"
                                class="botaoCad" style="background:blue;color:#fff;font-size:12px;width:121px">Inserir Pontuação</button> 
                            </div>
                            <div align="right" style="margin-top:20px;">
                                <button onClick="fechaCalculadoraCad()" onmouseOver="this.style.backgroundColor='red';" onMouseOut="this.style.backgroundColor='darkred';"
                                class="botaoCad" style="background:darkred;color:#fff;font-size:12px;width:65px">Fechar</button> 
                            </div>
                        </div>
                    </div>
                    <!---Fim Calculadora de Pontuação--->   
            </form>


        </div>
        <style>
        .cke_top{
            <!--- background:#003366; --->
        }
        
        </style>

    <script>
    
   
    var local = "parametros.cfm";

        CKEDITOR.replace('cadItemOrientacao', {
            width: '100%',
            height: 50,   
            removePlugins: 'scayt',
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript'],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]

        });

        CKEDITOR.replace('cadItemPreRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',//corretor ortografico
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
                 '/',               
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]

        });

        CKEDITOR.replace('cadItemOrientacaoRelato', {
            width: '100%',
            height: 50,
            removePlugins: 'scayt',//corretor ortografico
            disableNativeSpellChecker: false,
            toolbar: [
                ['Preview', 'Print', '-' ],
                [ 'Cut', 'Copy', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
                [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript' ],
                [ 'NumberedList', 'BulvaredList', '-',  'Blockquote','-','Outdent', 'Indent', '-'],
                '/',
                ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
                ['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor','Maximize','Table'  ]
            ]

        });

        CKEDITOR.replace('cadItemAmostra', {
        width: '400',
        height: 50,
        toolbar: [	
            [ 'Preview', 'Paste','PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','-','NumberedList', 'BulvaredList','SpecialChar','-'],
            '/',
            ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-','TextColor','Maximize','Table']
        ]				
        });

        CKEDITOR.replace('cadItemNorma', {
        width: '400',
        height: 50,
        toolbar: [	
            [ 'Preview', 'Paste', 'PasteText', 'RemoveFormat',  '-', 'Undo', 'Redo','-', 'Bold', 'Italic', '-', 'SelectAll','-','NumberedList', 'BulvaredList','SpecialChar','-'],
            '/',
            ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-','TextColor','Maximize', 'Table' ]
        ]	
        });



    </script>
           
    </body>

</html>