describe 'compiling jsx data' do
  subject do
    require 'react/jsx'
    jsx = <<-EOF
/** @jsx React.DOM */
React.renderComponent(
  <h1>Hello, world!</h1>,
  document.getElementById('example')
);
    EOF
    React::JSX.compile(jsx)
  end

  it 'should write a nice string' do
    subject.should eq(<<-EOF
/** @jsx React.DOM */
React.renderComponent(
  React.DOM.h1(null, "Hello, world!"),
  document.getElementById('example')
);
EOF
    )
  end
end
