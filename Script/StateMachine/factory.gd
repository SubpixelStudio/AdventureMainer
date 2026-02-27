extends Node

class_name PlayerFactory

enum PlayerState {
	NONE,
	IDLE,
	WALK,
	ATTACK,
	BLOCK,
}

func None():
	return PlayerState.NONE


func Idle():
	return PlayerState.IDLE


func Walk():
	return PlayerState.WALK


func Attack():
	return PlayerState.ATTACK


func Block():
	return PlayerState.BLOCK
