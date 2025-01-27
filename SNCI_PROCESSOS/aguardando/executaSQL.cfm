<cfprocessingdirective pageencoding = "utf-8">	
<cftransaction>
    <cfset dadosAceitos = [
        {codigo = 3568, status = "A"},
        {codigo = 3569, status = "A"},
        {codigo = 3570, status = "A"},
        {codigo = 3571, status = "A"},
        {codigo = 3573, status = "A"},
        {codigo = 3574, status = "A"},
        {codigo = 3575, status = "A"},
        {codigo = 3576, status = "A"},
        {codigo = 3577, status = "A"},
        {codigo = 3578, status = "A"},
        {codigo = 3579, status = "A"},
        {codigo = 3580, status = "A"},
        {codigo = 3582, status = "A"},
        {codigo = 3584, status = "A"},
        {codigo = 3587, status = "A"},
        {codigo = 3589, status = "A"},
        {codigo = 3591, status = "A"},
        {codigo = 3599, status = "A"},
        {codigo = 3600, status = "A"},
        {codigo = 3603, status = "A"},
        {codigo = 3604, status = "A"},
        {codigo = 3607, status = "A"},
        {codigo = 3608, status = "A"},
        {codigo = 3611, status = "A"},
        {codigo = 3612, status = "A"},
        {codigo = 3613, status = "A"},
        {codigo = 3614, status = "A"},
        {codigo = 3615, status = "A"},
        {codigo = 4619, status = "A"},
        {codigo = 4621, status = "A"},
        {codigo = 4622, status = "A"},
        {codigo = 4623, status = "A"},
        {codigo = 4624, status = "A"},
        {codigo = 4626, status = "A"},
        {codigo = 4627, status = "A"},
        {codigo = 4629, status = "A"},
        {codigo = 4630, status = "A"},
        {codigo = 4631, status = "A"},
        {codigo = 4715, status = "A"},
        {codigo = 4716, status = "A"},
        {codigo = 4717, status = "A"},
        {codigo = 4755, status = "A"},
        {codigo = 4756, status = "A"},
        {codigo = 4757, status = "A"},
        {codigo = 4760, status = "A"},
        {codigo = 4761, status = "A"},
        {codigo = 4762, status = "A"},
        {codigo = 4848, status = "A"},
        {codigo = 4849, status = "A"},
        {codigo = 4850, status = "A"},
        {codigo = 4851, status = "A"},
        {codigo = 4853, status = "A"},
        {codigo = 4892, status = "A"},
        {codigo = 4893, status = "A"},
        {codigo = 4894, status = "A"},
        {codigo = 4896, status = "A"},
        {codigo = 4960, status = "A"},
        {codigo = 4962, status = "A"},
        {codigo = 4963, status = "A"},
        {codigo = 4964, status = "A"},
        {codigo = 4967, status = "A"},
        {codigo = 4968, status = "A"},
        {codigo = 4990, status = "A"},
        {codigo = 4992, status = "A"},
        {codigo = 4993, status = "A"},
        {codigo = 4994, status = "A"},
        {codigo = 4995, status = "A"},
        {codigo = 4996, status = "A"},
        {codigo = 4999, status = "A"},
        {codigo = 5000, status = "A"},
        {codigo = 5001, status = "A"},
        {codigo = 5003, status = "A"},
        {codigo = 5004, status = "A"},
        {codigo = 5005, status = "A"},
        {codigo = 5006, status = "A"},
        {codigo = 5007, status = "A"},
        {codigo = 5008, status = "A"},
        {codigo = 5009, status = "A"},
        {codigo = 5011, status = "A"}

    ]>

    <!--- Contar a quantidade de itens no array --->
    <cfset totalAceitos = ArrayLen(dadosAceitos)>

    <!--- Loop para atualizar o banco de dados --->
    <cfoutput><h3>Registros Aceitos atualizados: #totalAceitos#</h3></cfoutput>
    <cfloop array="#dadosAceitos#" index="registro">
        <cfquery datasource="#application.dsn_processos#">
            UPDATE pc_avaliacao_melhorias
            SET 
            pc_aval_melhoria_status = <cfqueryparam value="#registro.status#" cfsqltype="cf_sql_varchar">,
            pc_aval_melhoria_naoAceita_justif = null,
            pc_aval_melhoria_sugestao = null
            WHERE pc_aval_melhoria_id = <cfqueryparam value="#registro.codigo#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfoutput>#registro.codigo#, </cfoutput>
    </cfloop>


    <cfset dadosPendentes = [
        {codigo = 3585, status = "P"},
        {codigo = 3586, status = "P"},
        {codigo = 3590, status = "P"},
        {codigo = 3592, status = "P"},
        {codigo = 3593, status = "P"},
        {codigo = 3594, status = "P"},
        {codigo = 4714, status = "P"},
        {codigo = 4738, status = "P"},
        {codigo = 4739, status = "P"},
        {codigo = 4740, status = "P"},
        {codigo = 4741, status = "P"},
        {codigo = 4742, status = "P"},
        {codigo = 4743, status = "P"},
        {codigo = 4744, status = "P"},
        {codigo = 4745, status = "P"},
        {codigo = 4746, status = "P"},
        {codigo = 4750, status = "P"},
        {codigo = 4751, status = "P"},
        {codigo = 4752, status = "P"},
        {codigo = 4753, status = "P"},
        {codigo = 4754, status = "P"},
        {codigo = 4758, status = "P"},
        {codigo = 4895, status = "P"},
        {codigo = 4970, status = "P"},
        {codigo = 4971, status = "P"},
        {codigo = 4973, status = "P"},
        {codigo = 4974, status = "P"},
        {codigo = 4975, status = "P"},
        {codigo = 4976, status = "P"},
        {codigo = 4977, status = "P"},
        {codigo = 4978, status = "P"},
        {codigo = 4979, status = "P"},
        {codigo = 4997, status = "P"},
        {codigo = 4998, status = "P"}
    ]>

    <!--- Contar a quantidade de itens no array --->
    <cfset totalPendentes = ArrayLen(dadosPendentes)>

    <!--- Loop para atualizar o banco de dados --->
    <cfoutput><h3>Registros Pendentes atualizados: #totalPendentes#</h3> </cfoutput>
    <cfloop array="#dadosPendentes#" index="registro">
        <cfquery datasource="#application.dsn_processos#">
            UPDATE pc_avaliacao_melhorias
            SET 
            pc_aval_melhoria_status = <cfqueryparam value="#registro.status#" cfsqltype="cf_sql_varchar">,
            pc_aval_melhoria_naoAceita_justif = null,
            pc_aval_melhoria_sugestao = null
            WHERE pc_aval_melhoria_id = <cfqueryparam value="#registro.codigo#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfoutput>#registro.codigo#, </cfoutput>
    </cfloop>

     <cfset dadosPendentesRefazer = [
        {codigo = 3583, status = "P"},
        {codigo = 3585, status = "P"},
        {codigo = 3586, status = "P"},
        {codigo = 3588, status = "P"},
        {codigo = 3590, status = "P"},
        {codigo = 3592, status = "P"},
        {codigo = 3593, status = "P"},
        {codigo = 3594, status = "P"},
        {codigo = 4714, status = "P"},
        {codigo = 4738, status = "P"},
        {codigo = 4739, status = "P"},
        {codigo = 4740, status = "P"},
        {codigo = 4741, status = "P"},
        {codigo = 4742, status = "P"},
        {codigo = 4743, status = "P"},
        {codigo = 4744, status = "P"},
        {codigo = 4745, status = "P"},
        {codigo = 4746, status = "P"},
        {codigo = 4749, status = "P"},
        {codigo = 4750, status = "P"},
        {codigo = 4751, status = "P"},
        {codigo = 4752, status = "P"},
        {codigo = 4753, status = "P"},
        {codigo = 4754, status = "P"},
        {codigo = 4758, status = "P"},
        {codigo = 4763, status = "P"},
        {codigo = 4764, status = "P"},
        {codigo = 4765, status = "P"},
        {codigo = 4767, status = "P"},
        {codigo = 4768, status = "P"},
        {codigo = 4895, status = "P"},
        {codigo = 4958, status = "P"},
        {codigo = 4959, status = "P"},
        {codigo = 4961, status = "P"},
        {codigo = 4965, status = "P"},
        {codigo = 4966, status = "P"},
        {codigo = 4969, status = "P"},
        {codigo = 4970, status = "P"},
        {codigo = 4971, status = "P"},
        {codigo = 4972, status = "P"},
        {codigo = 4973, status = "P"},
        {codigo = 4974, status = "P"},
        {codigo = 4975, status = "P"},
        {codigo = 4976, status = "P"},
        {codigo = 4977, status = "P"},
        {codigo = 4978, status = "P"},
        {codigo = 4979, status = "P"},
        {codigo = 4991, status = "P"},
        {codigo = 4997, status = "P"},
        {codigo = 4998, status = "P"}
    ]>

    <!--- Contar a quantidade de itens no array --->
    <cfset totalPendentesRefazer = ArrayLen(dadosPendentesRefazer)>

    <!--- Loop para atualizar o banco de dados --->
    <cfoutput><h3>Registros Pendentes Refazer atualizados: #totalPendentesRefazer#</h3></cfoutput>
    <cfloop array="#dadosPendentesRefazer#" index="registro">
        <cfquery datasource="#application.dsn_processos#">
            UPDATE pc_avaliacao_melhorias
            SET 
            pc_aval_melhoria_status = <cfqueryparam value="#registro.status#" cfsqltype="cf_sql_varchar">,
            pc_aval_melhoria_naoAceita_justif = null,
            pc_aval_melhoria_sugestao = null
            WHERE pc_aval_melhoria_id = <cfqueryparam value="#registro.codigo#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfoutput>#registro.codigo#, </cfoutput>
    </cfloop>

    <cfset totalRegistros = totalAceitos + totalPendentes + totalPendentesRefazer>

    <cfoutput><h2>Total de registros atualizados: #totalRegistros#</h2></cfoutput>

</cftransaction>
   



 