/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
  NativeModules,
} from 'react-native';

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
    'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

const options = {
  http: 'http://192.168.24.143:8080',
  token: '22057889-5d6c-434a-a514-0989fce53516',
  index: '2',
  monitorId: '5fd654a9-7185-4cee-8f6e-78bf5ec462a3',
  monitorName: '张三德',
  platform: 'ios',
  version: '20000',
};

type Props = {};
export default class App extends Component<Props> {

  constructor(props) {
    super(props);
    this.state = {
      index: 0,
    };
  }

  componentDidMount() {
    // setInterval(() => {
    //   const { index } = this.state;
    //   this.setState({ index: index + 1 });
    // }, 1000);
  }

  componentWillUnmount() {
    
  }

  clickBtn = (index) => {
    NativeModules.RNBridgeModule.backToViewController(options);
  }

  render() {
    const { index } = this.state;

    return (
      <View style={styles.container}>
        <Text>原生与RN交互测试</Text>
        <TouchableHighlight onPress={() => this.clickBtn(1)}>
          <Text>监控对象-人</Text>
        </TouchableHighlight>
        <TouchableHighlight onPress={() => this.clickBtn(2)}>
          <Text>监控对象-车</Text>
        </TouchableHighlight>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
