import dash
import dash_html_components as html
import dash_core_components as dcc
import pickle
import numpy as np
import plotly.graph_objs as go

def init():
    with open("clf_model.pickle", "rb") as f:
        model = pickle.load(f)
    return model

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

# graph div
app.layout = html.Div([
    html.H1('Article Classification',
            style={'textAlign':'center'}),
    html.Div(dcc.Input(id='input-box', type='text',
                       style={'width': '100%', 'display': 'inline-block'})),
    html.Button('Submit', id='button',
                ),
    html.Div(id='container-button-basic',
             children='기사제목을 입력해주세요'),
    dcc.Graph(id='live-update-graph'),
],
    style={'maxWidth': '650px'}
)

@app.callback(
    dash.dependencies.Output(component_id='live-update-graph', component_property='figure'),
    [dash.dependencies.Input(component_id='button', component_property='n_clicks')],
    [dash.dependencies.State(component_id='input-box', component_property='value')])
def update_output(n_clicks, value):
    if value is not None:
        sentence = value
        print(sentence)
        values = list(np.round_(model.predict_proba([sentence])[0] * 100, 2))
    else:
        values = [0]*5

    labels = ['IT과학', '경제', '사회', '생활문화', '세계', '정치']
    data = go.Pie(labels=labels, values=values)
    layout = go.Layout(
        autosize=False,
        width=800,
        height=800,
        font=dict(family='Courier New, monospace', size=18, color='#7f7f7f')
    )

    fig = go.Figure(data=[data], layout=layout)

    return fig


if __name__ == '__main__':
    model = init()
    app.run_server(debug=True)

