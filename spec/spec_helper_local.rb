shared_examples 'fail' do
  it 'fails' do
    expect { subject.call }.to raise_error(/#{regex}/)
  end
end
