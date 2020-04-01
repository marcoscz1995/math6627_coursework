def function_latex_maker(model_type, response, linear_predictors, mixed_predictors, label, n,random_levels, tex_name):
    doc = []
    doc.append(r'\begin{align}')
    doc.append(r'\begin{split}')
    num_of_predictors =  len(linear_predictors) + 1
    betas = [r'\beta_{'+ str(i) +r'}' for i in range(1,num_of_predictors)] #exclludes beta0
    index = 'i' if model_type == 'linear' else 'ij'
    predictors = [r'\text{'+predictor +'}'+ r'_{'+index+r'}' for predictor in linear_predictors]
    if model_type == 'mixed' :
        i_term = r'i=\{1,...,' + 'n_j\},'
        j_term = r'j=\{'+random_levels[0]+',...,' + random_levels[-2] +', ' + random_levels[-1]+'\}'
        fixed_predictors = list(set(linear_predictors) - set(mixed_predictors)) #predictors w/out RanSope
        fixed_predictors = [r'\text{'+predictor +'}' + r'_{'+index+r'}' for predictor in fixed_predictors]
        mixed_predictors = [r'\text{'+predictor +'}'+ r'_{'+index+r'}' for predictor in mixed_predictors]
        num_of_fixed_predictors = len(fixed_predictors)
        num_of_mixed_predictors = len(mixed_predictors)
        start_num_for_random_slopes = num_of_fixed_predictors #note:|fixed predictors|>=|mixed predictors|
        range_of_random_slopes = list(range(1,(num_of_mixed_predictors+1))) if num_of_mixed_predictors > 1 else [1]

        random_slopes = ['b_{' +str(i)+'j}' for i in range_of_random_slopes] #excludes b_0 and starts off at num_of_fixed_predictors +1

        fixed_effects = ["{}{}".format(beta, predictor) for beta, predictor in zip(betas[:num_of_fixed_predictors], fixed_predictors)]
        fixed_effects='+'.join(fixed_effects)
#        import pdb; pdb.set_trace()
        random_effects = ["+({}+{}){}".format(beta,b, predictor) for beta, b, predictor in zip(betas[(start_num_for_random_slopes):],random_slopes,  mixed_predictors)]
    else :
        i_term = r'i=\{1,...,' + str(n) + '\}'
        beta_predictor = ["{}{}".format(beta, predictor) for beta, predictor in zip(betas, predictors)]
        beta_predictor = '+'.join(beta_predictor)
    response = r'\text{' + response + '}' + r'_{'+index+'}&='
    epsilon = r'+\varepsilon_{'+index+'}'
    if model_type == 'mixed' :
        formula = response+r'\beta_0+'+r'b_{0j}'+ str(random_effects[0])+r'\\'+' &' +str(random_effects[1])+str(random_effects[2])+ r'\\'+' &' +str(random_effects[3])+ epsilon + r'\\'
    else :
        formula = response+r'\beta_0+'+ beta_predictor + epsilon + r'\\'
    doc.append(formula)
    doc.append(r'\end{split}')
    doc.append(r'\label{'+label+r'}')
    doc.append(r'\end{align}')
    doc.append(r'\begin{equation*}')
    doc.append(i_term)
    if model_type != 'linear' :
        doc.append(j_term)
    doc.append(r'\end{equation*}')
    for line in doc :
        print(line)

    with open(tex_name, "w") as fobj:
        for line in doc:
            fobj.write(line + "\n")
    return

#model_type = 'linear'
model_type = 'mixed'
econ_response = 'Economic Cost'
human_response = 'Human Cost'
random_levels_prov = ['Alberta', 'Manitoba', 'Ontario', 'Quebec']
random_levels_time = ['1910', '1920', '2008', '2014']
mixed_predictors = ['Event Type','Event Duration','Magnitude', 'Num.Prov. Involved']
linear_predictors = mixed_predictors
n=1114

function_latex_maker(model_type, econ_response, linear_predictors, mixed_predictors, 'econ_province', n,random_levels_prov, 'econ_province.tex')

function_latex_maker(model_type, econ_response, linear_predictors, mixed_predictors, 'econ_time', n,random_levels_time, 'econ_time.tex')

function_latex_maker(model_type, human_response, linear_predictors, mixed_predictors, 'human_province', n,random_levels_prov, 'human_province.tex')

function_latex_maker(model_type, human_response, linear_predictors, mixed_predictors, 'human_time.tex', n,random_levels_time, 'human_time.tex')

